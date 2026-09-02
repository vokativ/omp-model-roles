#!/usr/bin/env bash
# ==============================================================================
# omp-wt: Git Worktree Manager for OMP (Oh My Pi)
# Works on Linux, macOS, Meta Quest (Termux), and Windows (Git Bash / WSL)
# ==============================================================================

set -eo pipefail

# Visual styling
if [ -t 1 ]; then
    BOLD="\033[1m"
    GREEN="\033[32m"
    YELLOW="\033[33m"
    CYAN="\033[36m"
    BLUE="\033[34m"
    MAGENTA="\033[35m"
    DIM="\033[2m"
    RED="\033[31m"
    RESET="\033[0m"
else
    BOLD="" GREEN="" YELLOW="" CYAN="" BLUE="" MAGENTA="" DIM="" RED="" RESET=""
fi

show_intro_guide() {
    cat << EOF
${BOLD}${CYAN}================================================================================${RESET}
${BOLD}${MAGENTA}                Git Worktrees & OMP: The Beginner's Guide${RESET}
${BOLD}${CYAN}================================================================================${RESET}

${BOLD}1. WHAT IS A GIT WORKTREE?${RESET}
   Normally, Git gives you ${BOLD}one${RESET} folder for your project. When you switch branches,
   Git changes the files inside that one folder. If you have uncommitted edits or
   running servers/tests, switching branches can be messy or cause conflicts.

   A ${BOLD}Git Worktree${RESET} allows you to have ${GREEN}multiple folders for the same project${RESET} open
   simultaneously on your disk, all connected to the ${CYAN}same Git history${RESET}:

      ┌────────────────────────────────────────────────────────┐
      │               Shared Git Database (.git)               │
      │         (all commits, branches, stashes, history)      │
      └───────────┬───────────────────┬───────────────────┬────┘
                  │                   │                   │
        ┌─────────┴─────────┐ ┌───────┴─────────┐ ┌───────┴─────────┐
        │   Main Directory  │ │ Worktree: exp-1 │ │ Worktree: exp-2 │
        │   (branch: main)  │ │ (branch: exp-1) │ │ (branch: exp-2) │
        └───────────────────┘ └─────────────────┘ └─────────────────┘

${BOLD}2. WHY USE IT WITH OMP?${RESET}
   • ${GREEN}Zero file conflicts:${RESET} Let OMP rewrite files, run tests, or install packages
     in an isolated worktree while your main code remains 100% untouched.
   • ${GREEN}Parallel investigations:${RESET} Run multiple OMP agents in parallel on different
     ideas or bug investigations without switching back and forth.
   • ${GREEN}Fast & lightweight:${RESET} Creating a worktree takes 0.1 seconds because it uses
     the local Git database already on your computer (no re-cloning).

${BOLD}3. THE 3-STEP WORKFLOW:${RESET}
   ${CYAN}Step 1: Start an investigation${RESET}
     $ omp-wt investigate-auth
     (Creates .worktrees/investigate-auth, sets up the branch, and starts OMP)

   ${CYAN}Step 2: Let OMP work${RESET}
     (OMP makes edits and commits inside the worktree)

   ${CYAN}Step 3: Decide what to keep${RESET}
     • If you like the result: Merge it into your main branch!
       $ git merge investigate-auth
     • If you want to discard or clean up when finished:
       $ omp-wt rm investigate-auth

${BOLD}4. IMPORTANT THINGS TO KNOW:${RESET}
   • ${YELLOW}One branch per worktree:${RESET} Git will not let two worktrees checkout the same
     branch at the same time. This prevents conflicting changes.
   • ${YELLOW}Local files (.env, keystores):${RESET} Files ignored by Git are not copied
     automatically. omp-wt will detect common local files and ask to copy them for you.
${BOLD}${CYAN}================================================================================${RESET}
EOF
}

show_help() {
    cat << EOF
${BOLD}omp-wt${RESET} - Launch OMP in an isolated Git Worktree

${BOLD}USAGE:${RESET}
    ${CYAN}omp-wt${RESET}                      Interactive wizard (prompts for name & base)
    ${CYAN}omp-wt <name>${RESET}               Create/open worktree <name> and launch OMP
    ${CYAN}omp-wt <name> <base-ref>${RESET}    Create worktree <name> starting from <base-ref>
    ${CYAN}omp-wt <name> -- [args...]${RESET}  Pass extra flags to OMP (e.g. --model smol)

${BOLD}COMMANDS:${RESET}
    ${GREEN}omp-wt list, ls${RESET}             List all active worktrees with status & age
    ${GREEN}omp-wt rm, remove <name>${RESET}    Delete a worktree and clean up git references
    ${GREEN}omp-wt prune${RESET}                Clean up stale worktree metadata
    ${GREEN}omp-wt path <name>${RESET}          Print the absolute path to a worktree
    ${GREEN}omp-wt guide, intro${RESET}         Show beginner visual guide to worktrees
    ${GREEN}omp-wt help, -h, --help${RESET}     Show this help screen

${BOLD}OPTIONS & FLAGS:${RESET}
    ${YELLOW}--copy-env${RESET}                  Automatically copy detected local config (.env, keystores)
    ${YELLOW}--no-copy-env${RESET}               Skip copying local configuration files
    ${YELLOW}--sibling${RESET}                   Create worktree as a sibling directory (../<repo>-<name>)
    ${YELLOW}--nested${RESET}                    Create worktree inside project (.worktrees/<name>) [Default]

${BOLD}ENVIRONMENT VARIABLES:${RESET}
    ${DIM}OMP_WT_MODE${RESET}                 "nested" (default) or "sibling"
    ${DIM}OMP_BIN${RESET}                     Path to omp binary (default: auto-detected in PATH)

${BOLD}EXAMPLES:${RESET}
    omp-wt                      # Interactive mode
    omp-wt fix-login            # Quick create & launch
    omp-wt spike-db main        # Branch from main
    omp-wt list                 # See all active worktrees
    omp-wt rm fix-login         # Clean up when done
    omp-wt guide                # Read the beginner's guide
EOF
}

# Verify Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}Error:${RESET} Not inside a Git repository." >&2
    exit 1
fi

# Locate common/main git directory and project root
COMMON_GIT_DIR="$(git rev-parse --git-common-dir 2>/dev/null || git rev-parse --git-dir)"
if [[ "$COMMON_GIT_DIR" != /* ]]; then
    COMMON_GIT_DIR="$(cd "$COMMON_GIT_DIR" && pwd)"
fi

if [ -d "$COMMON_GIT_DIR" ] && [ "$(basename "$COMMON_GIT_DIR")" = ".git" ]; then
    MAIN_REPO_ROOT="$(dirname "$COMMON_GIT_DIR")"
else
    MAIN_REPO_ROOT="$(git rev-parse --show-toplevel)"
fi

REPO_NAME="$(basename "$MAIN_REPO_ROOT")"

# Ensure OMP binary is found
OMP_EXEC="${OMP_BIN:-$(which omp 2>/dev/null || echo "")}"
if [ -z "$OMP_EXEC" ]; then
    if [ -x "$HOME/.local/bin/omp" ]; then
        OMP_EXEC="$HOME/.local/bin/omp"
    fi
fi

# Worktree location resolver
get_worktree_path() {
    local name="$1"
    local mode="${OMP_WT_MODE:-nested}"
    if [ "$mode" = "sibling" ]; then
        echo "$(dirname "$MAIN_REPO_ROOT")/${REPO_NAME}-${name}"
    else
        echo "${MAIN_REPO_ROOT}/.worktrees/${name}"
    fi
}

# Auto-exclude .worktrees from git status if nested
ensure_exclude() {
    local exclude_file="${COMMON_GIT_DIR}/info/exclude"
    mkdir -p "$(dirname "$exclude_file")" 2>/dev/null || true
    if [ -f "$exclude_file" ]; then
        if ! grep -qxF ".worktrees" "$exclude_file" 2>/dev/null && ! grep -qxF ".worktrees/" "$exclude_file" 2>/dev/null; then
            echo ".worktrees/" >> "$exclude_file"
        fi
    else
        echo ".worktrees/" > "$exclude_file"
    fi
}

# Human-readable worktree listing
print_wt_item() {
    local path="$1"
    local branch="$2"
    local head="$3"
    local main_root="$4"
    
    local name
    local tag
    if [ "$path" = "$main_root" ]; then
        name="main"
        tag="${MAGENTA}[main root]${RESET}"
    else
        name="$(basename "$path")"
        tag="${BLUE}[worktree]${RESET}"
    fi
    
    local last_info
    last_info="$(git -C "$path" log -1 --format="%cr|%s (%h)" 2>/dev/null || echo "no commits|no commits")"
    local time_ago="${last_info%%|*}"
    local commit_msg="${last_info#*|}"
    
    local dirty_count
    dirty_count="$(git -C "$path" status --porcelain 2>/dev/null | wc -l || echo 0)"
    local status_badge
    if [ "$dirty_count" -eq 0 ]; then
        status_badge="${GREEN}✓ clean${RESET}"
    else
        status_badge="${YELLOW}● $dirty_count uncommitted file(s)${RESET}"
    fi

    echo -e "  ${BOLD}• ${name}${RESET} ${tag} ${CYAN}(branch: ${branch:-HEAD})${RESET}"
    echo -e "    Status: ${status_badge}"
    echo -e "    Latest: ${commit_msg} ${DIM}(${time_ago})${RESET}"
    echo -e "    Path:   ${DIM}${path}${RESET}"
    echo ""
}

list_worktrees() {
    echo -e "${BOLD}${CYAN}Git Worktrees for ${GREEN}${REPO_NAME}${RESET}:"
    echo ""

    local current_wt=""
    local current_head=""
    local current_branch=""
    
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^worktree\ (.*) ]]; then
            if [ -n "$current_wt" ]; then
                print_wt_item "$current_wt" "$current_branch" "$current_head" "$MAIN_REPO_ROOT"
            fi
            current_wt="${BASH_REMATCH[1]}"
            current_head=""
            current_branch=""
        elif [[ "$line" =~ ^HEAD\ (.*) ]]; then
            current_head="${BASH_REMATCH[1]:0:7}"
        elif [[ "$line" =~ ^branch\ refs/heads/(.*) ]]; then
            current_branch="${BASH_REMATCH[1]}"
        elif [[ "$line" == "detached" ]]; then
            current_branch="(detached HEAD)"
        fi
    done < <(git worktree list --porcelain)

    if [ -n "$current_wt" ]; then
        print_wt_item "$current_wt" "$current_branch" "$current_head" "$MAIN_REPO_ROOT"
    fi

    echo -e "${BOLD}Next Actions:${RESET}"
    echo -e "  ${CYAN}omp-wt <name>${RESET}          Launch OMP in that worktree"
    echo -e "  ${YELLOW}omp-wt rm <name>${RESET}       Delete worktree and its branch"
    echo -e "  ${GREEN}git merge <branch>${RESET}     Merge changes into your current branch"
    echo ""
}

# Scan for untracked config and secrets in main repo
handle_untracked_configs() {
    local target_wt="$1"
    local auto_copy="$2" # "yes", "no", or "prompt"

    # Known untracked config patterns across Web, Android, iOS, Python, etc.
    local check_patterns=(
        ".env" ".env.local" ".env.development" ".env.development.local"
        ".env.production" ".env.production.local" ".env.test" ".env.staging"
        ".npmrc" ".yarnrc" ".yarnrc.yml"
        "local.properties" "android/local.properties"
        "*.keystore" "*.jks" "android/*.keystore" "android/*.jks"
        "android/app/*.keystore" "android/app/*.jks"
        "google-services.json" "android/app/google-services.json"
        "android/secrets.properties" "secrets.properties"
        "GoogleService-Info.plist" "ios/GoogleService-Info.plist" "ios/Runner/GoogleService-Info.plist"
        "secrets.yaml" "secrets.json" "config.local.json" "local_settings.py"
    )

    shopt -s nullglob
    local found_configs=()
    for pat in "${check_patterns[@]}"; do
        for f in "$MAIN_REPO_ROOT"/$pat; do
            if [ -f "$f" ]; then
                local rel="${f#$MAIN_REPO_ROOT/}"
                # Check if it's already in destination
                if [ ! -f "$target_wt/$rel" ]; then
                    found_configs+=("$rel")
                fi
            fi
        done
    done
    shopt -u nullglob

    if [ ${#found_configs[@]} -eq 0 ]; then
        return 0
    fi

    echo -e "${YELLOW}Notice:${RESET} Local configuration files detected in main repository:"
    for cf in "${found_configs[@]}"; do
        echo -e "  ${DIM}•${RESET} ${cf}"
    done
    echo -e "${DIM}(These files are ignored by Git and not automatically in the worktree)${RESET}"

    local do_copy="n"
    if [ "$auto_copy" = "yes" ]; then
        do_copy="y"
    elif [ "$auto_copy" = "no" ]; then
        do_copy="n"
    else
        echo -ne "${BOLD}Copy these files to the new worktree? [Y/n]: ${RESET}"
        read -r CONFIRM_COPY
        if [[ -z "$CONFIRM_COPY" || "$CONFIRM_COPY" =~ ^[Yy]$ ]]; then
            do_copy="y"
        fi
    fi

    if [ "$do_copy" = "y" ]; then
        for cf in "${found_configs[@]}"; do
            mkdir -p "$(dirname "$target_wt/$cf")"
            cp "$MAIN_REPO_ROOT/$cf" "$target_wt/$cf"
        done
        echo -e "${GREEN}✓ Copied ${#found_configs[@]} config file(s) to worktree.${RESET}\n"
    else
        echo -e "${DIM}Skipped copying. If needed, copy manually with:${RESET}"
        for cf in "${found_configs[@]}"; do
            echo -e "  cp \"${MAIN_REPO_ROOT}/${cf}\" \"${target_wt}/${cf}\""
        done
        echo ""
    fi
}

# Subcommands
case "${1:-}" in
    -h|--help|help)
        show_help
        exit 0
        ;;
    guide|intro|explain)
        show_intro_guide
        exit 0
        ;;
    list|ls)
        list_worktrees
        exit 0
        ;;
    prune)
        echo -e "${CYAN}Pruning stale worktrees...${RESET}"
        git worktree prune -v
        exit 0
        ;;
    rm|remove|delete)
        if [ -z "${2:-}" ]; then
            echo -e "${RED}Error:${RESET} Please specify the worktree name to remove." >&2
            echo -e "Usage: ${BOLD}omp-wt rm <name>${RESET}" >&2
            exit 1
        fi
        TARGET_NAME="$2"
        TARGET_PATH="$(get_worktree_path "$TARGET_NAME")"
        
        if [ ! -d "$TARGET_PATH" ]; then
            MATCH="$(git worktree list --porcelain | grep "^worktree " | cut -d' ' -f2- | grep -E "(^|/)${TARGET_NAME}$" | head -n 1 || true)"
            if [ -n "$MATCH" ]; then
                TARGET_PATH="$MATCH"
            fi
        fi

        if [ ! -d "$TARGET_PATH" ]; then
            echo -e "${RED}Error:${RESET} Worktree '${TARGET_NAME}' not found at ${TARGET_PATH}." >&2
            exit 1
        fi

        echo -e "${YELLOW}Removing worktree:${RESET} ${TARGET_PATH}"
        if git worktree remove "$TARGET_PATH" 2>/dev/null; then
            echo -e "${GREEN}✓ Worktree directory removed.${RESET}"
        else
            echo -e "${YELLOW}Standard remove failed (uncommitted files or lock). Force remove? [y/N]${RESET} "
            read -r CONFIRM
            if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
                git worktree remove --force "$TARGET_PATH"
                echo -e "${GREEN}✓ Worktree force-removed.${RESET}"
            else
                echo -e "${DIM}Aborted.${RESET}"
                exit 1
            fi
        fi

        if git show-ref --verify --quiet "refs/heads/${TARGET_NAME}"; then
            echo -ne "${YELLOW}Delete branch '${TARGET_NAME}' too? [y/N]${RESET} "
            read -r DEL_BRANCH
            if [[ "$DEL_BRANCH" =~ ^[Yy]$ ]]; then
                git branch -D "$TARGET_NAME" 2>/dev/null || true
                echo -e "${GREEN}✓ Branch '${TARGET_NAME}' deleted.${RESET}"
            fi
        fi
        exit 0
        ;;
    path)
        if [ -z "${2:-}" ]; then
            echo -e "${RED}Error:${RESET} Specify worktree name." >&2
            exit 1
        fi
        get_worktree_path "$2"
        exit 0
        ;;
esac

# Collect arguments
WT_NAME=""
BASE_REF=""
AUTO_COPY_ENV="prompt"
EXTRA_OMP_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --)
            shift
            EXTRA_OMP_ARGS=("$@")
            break
            ;;
        --sibling)
            OMP_WT_MODE="sibling"
            shift
            ;;
        --nested)
            OMP_WT_MODE="nested"
            shift
            ;;
        --copy-env)
            AUTO_COPY_ENV="yes"
            shift
            ;;
        --no-copy-env)
            AUTO_COPY_ENV="no"
            shift
            ;;
        *)
            if [ -z "$WT_NAME" ]; then
                WT_NAME="$1"
            elif [ -z "$BASE_REF" ]; then
                BASE_REF="$1"
            else
                EXTRA_OMP_ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

# Interactive mode if name not provided
if [ -z "$WT_NAME" ]; then
    CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "HEAD")"
    
    echo -e "${BOLD}${CYAN}=== OMP Git Worktree Launcher ===${RESET}"
    echo -e "${DIM}Repository:${RESET}     ${GREEN}${MAIN_REPO_ROOT}${RESET} (${CYAN}${REPO_NAME}${RESET})"
    echo -e "${DIM}Current branch:${RESET} ${YELLOW}${CURRENT_BRANCH}${RESET}"
    echo -e "${DIM}(Type 'omp-wt guide' anytime for an introduction to worktrees)${RESET}\n"
    
    ACTIVE_COUNT="$(git worktree list | wc -l)"
    if [ "$ACTIVE_COUNT" -gt 1 ]; then
        echo -e "${BOLD}Active worktrees:${RESET}"
        list_worktrees
    fi

    while [ -z "$WT_NAME" ]; do
        echo -ne "${BOLD}Enter worktree/branch name (e.g. fix-auth, test-speed): ${RESET}"
        read -r WT_NAME
        WT_NAME="$(echo "$WT_NAME" | tr -d '[:space:]')"
    done

    echo -ne "${BOLD}Base branch/commit [${YELLOW}${CURRENT_BRANCH}${RESET}${BOLD}]: ${RESET}"
    read -r USER_BASE_REF
    if [ -n "$USER_BASE_REF" ]; then
        BASE_REF="$USER_BASE_REF"
    else
        BASE_REF="$CURRENT_BRANCH"
    fi
fi

# Clean / sanitize worktree name
WT_NAME="$(echo "$WT_NAME" | sed 's|^/||; s|/$||')"
WT_PATH="$(get_worktree_path "$WT_NAME")"

# Ensure .worktrees/ is excluded if nested
ensure_exclude

# Check if worktree directory already exists
if [ -d "$WT_PATH" ]; then
    echo -e "${CYAN}→ Opening existing worktree:${RESET} ${WT_PATH}"
else
    echo -e "${CYAN}→ Creating worktree:${RESET} ${BOLD}${WT_NAME}${RESET}"
    echo -e "${DIM}  Location:${RESET} ${WT_PATH}"
    
    mkdir -p "$(dirname "$WT_PATH")"

    if git show-ref --verify --quiet "refs/heads/${WT_NAME}"; then
        echo -e "${DIM}  Branch '${WT_NAME}' already exists, checking it out...${RESET}"
        git worktree add "$WT_PATH" "$WT_NAME"
    else
        BASE_REF="${BASE_REF:-HEAD}"
        echo -e "${DIM}  Creating new branch '${WT_NAME}' from ${BASE_REF}...${RESET}"
        git worktree add -b "$WT_NAME" "$WT_PATH" "$BASE_REF"
    fi
    echo -e "${GREEN}✓ Worktree ready!${RESET}\n"

    # Handle local configs & secrets
    handle_untracked_configs "$WT_PATH" "$AUTO_COPY_ENV"
fi

# Launch OMP in the worktree directory
if [ -z "$OMP_EXEC" ]; then
    echo -e "${YELLOW}Warning:${RESET} 'omp' command not found in PATH or ~/.local/bin/omp."
    echo -e "Entering directory: ${WT_PATH}"
    cd "$WT_PATH"
    exec "${SHELL:-/bin/bash}"
else
    echo -e "${GREEN}Launching OMP in:${RESET} ${WT_PATH}\n"
    cd "$WT_PATH"
    "$OMP_EXEC" "${EXTRA_OMP_ARGS[@]}"
fi
