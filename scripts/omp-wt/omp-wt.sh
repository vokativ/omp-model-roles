#!/usr/bin/env bash
# ==============================================================================
# omp-wt: Git Worktree Manager for OMP (Oh My Pi)
# Works on Linux, macOS, Meta Quest (Termux), and Windows (Git Bash / WSL)
# ==============================================================================

set -eo pipefail

# Visual styling
if [ -t 1 ]; then
    BOLD=$'\e[1m'
    GREEN=$'\e[32m'
    YELLOW=$'\e[33m'
    CYAN=$'\e[36m'
    BLUE=$'\e[34m'
    MAGENTA=$'\e[35m'
    DIM=$'\e[2m'
    RED=$'\e[31m'
    RESET=$'\e[0m'
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

${BOLD}3. WORKFLOW: STARTING, RETURNING, & MERGING:${RESET}
   ${CYAN}• Start a new investigation:${RESET}
     $ omp-wt investigate-auth
     (Creates .worktrees/investigate-auth, sets up branch, copies configs, starts OMP)

   ${CYAN}• Re-enter an EXISTING worktree with OMP (from project root):${RESET}
     $ omp-wt investigate-auth
     ${DIM}If the worktree already exists, omp-wt detects it and opens OMP right inside it!${RESET}
     ${DIM}Or just run 'omp-wt' with no arguments to see your worktree list and select it.${RESET}

   ${CYAN}• Just open a shell/terminal in that worktree (without OMP):${RESET}
     $ cd .worktrees/investigate-auth

   ${CYAN}• Merge completed work into your main branch:${RESET}
     $ git merge investigate-auth

   ${CYAN}• Clean up when finished:${RESET}
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

# Levenshtein distance calculation for typo detection
levenshtein() {
    local s1="$1" s2="$2"
    local len1=${#s1} len2=${#s2}
    local diff=$(( len1 > len2 ? len1 - len2 : len2 - len1 ))
    if [ "$diff" -gt 2 ]; then
        echo 99
        return
    fi
    declare -A d
    for ((i=0; i<=len1; i++)); do d[$i,0]=$i; done
    for ((j=0; j<=len2; j++)); do d[0,$j]=$j; done
    for ((i=1; i<=len1; i++)); do
        local c1="${s1:i-1:1}"
        for ((j=1; j<=len2; j++)); do
            local c2="${s2:j-1:1}"
            local cost=1
            [ "$c1" = "$c2" ] && cost=0
            local del=$(( d[$((i-1)),$j] + 1 ))
            local ins=$(( d[$i,$((j-1))] + 1 ))
            local sub=$(( d[$((i-1)),$((j-1))] + cost ))
            local min=$del
            [ "$ins" -lt "$min" ] && min=$ins
            [ "$sub" -lt "$min" ] && min=$sub
            d[$i,$j]=$min
        done
    done
    echo "${d[$len1,$len2]}"
}

suggest_command_typo() {
    local input="$1"
    local clean="${input#--}"
    clean="${clean#-}"
    clean="$(echo "$clean" | tr '[:upper:]' '[:lower:]')"

    # Common mistypes table
    case "$clean" in
        intor|itnro|inrto|intr|introo|introd|into|inro) echo "intro"; return ;;
        gudie|gide|guied|gude|giude|guid|giud|guie) echo "guide"; return ;;
        explian|explan|expln|exlpain|xplain) echo "explain"; return ;;
        lsit|listt|lis|lists|lit|lst|sl|lits) echo "list"; return ;;
        purne|prun|pruen|pune|prunne|pruner|pru) echo "prune"; return ;;
        remov|remvoe|rmv|del|delet|dlete|delt|remoev) echo "remove"; return ;;
        hepl|hlp|hlep|halp|hellp|hep|hel) echo "help"; return ;;
        pth|paht|ptah) echo "path"; return ;;
    esac

    # Fuzzy match with length-sensitive threshold
    local commands=("intro" "guide" "explain" "help" "list" "prune" "remove" "delete" "path")
    local best_match=""
    local min_dist=99
    local len=${#clean}
    local max_allowed=2
    if [ "$len" -le 4 ]; then
        max_allowed=1
    fi

    for cmd in "${commands[@]}"; do
        local dist=$(levenshtein "$clean" "$cmd")
        if [ "$dist" -le "$max_allowed" ] && [ "$dist" -lt "$min_dist" ]; then
            min_dist=$dist
            best_match="$cmd"
        fi
    done
    echo "$best_match"
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

# Check if $1 is a mistyped command
if [ -n "${1:-}" ]; then
    TYPO_SUGGESTION="$(suggest_command_typo "$1")"
    if [ -n "$TYPO_SUGGESTION" ]; then
        echo -e "${RED}Error:${RESET} Unknown command '${1}'. Did you mean '${CYAN}omp-wt ${TYPO_SUGGESTION}${RESET}'?" >&2
        echo -e "${DIM}Run 'omp-wt --help' for usage, or 'omp-wt guide' for an introduction.${RESET}" >&2
        exit 1
    fi
fi

# Collect arguments
WT_NAME=""
BASE_REF=""
AUTO_COPY_ENV="prompt"
AUTO_CONFIRM="no"
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
        -y|--yes)
            AUTO_CONFIRM="yes"
            shift
            ;;
        new|create|add)
            # Optional explicit verb (e.g. omp-wt new my-feat)
            shift
            ;;
        -*|--*)
            FLAG_SUGGESTION="$(suggest_command_typo "$1")"
            if [ -n "$FLAG_SUGGESTION" ]; then
                echo -e "${RED}Error:${RESET} Unrecognized option '${1}'. Did you mean '${CYAN}omp-wt ${FLAG_SUGGESTION}${RESET}'?" >&2
            else
                echo -e "${RED}Error:${RESET} Unrecognized option '${1}'." >&2
            fi
            echo -e "${DIM}Run 'omp-wt --help' to see valid options.${RESET}" >&2
            exit 1
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

        INTERACTIVE_TYPO="$(suggest_command_typo "$WT_NAME")"
        if [ "$WT_NAME" = "guide" ] || [ "$WT_NAME" = "intro" ] || [ "$WT_NAME" = "explain" ] || [ "$INTERACTIVE_TYPO" = "intro" ] || [ "$INTERACTIVE_TYPO" = "guide" ]; then
            echo -e "\n${YELLOW}Note:${RESET} '${WT_NAME}' detected. Showing guide...\n"
            show_intro_guide
            WT_NAME=""
        elif [ "$WT_NAME" = "help" ] || [ "$INTERACTIVE_TYPO" = "help" ]; then
            show_help
            WT_NAME=""
        elif [ "$WT_NAME" = "list" ] || [ "$WT_NAME" = "ls" ] || [ "$INTERACTIVE_TYPO" = "list" ]; then
            list_worktrees
            WT_NAME=""
        fi
    done
fi

# Clean / sanitize worktree name
WT_NAME="$(echo "$WT_NAME" | sed 's|^/||; s|/$||')"
WT_PATH="$(get_worktree_path "$WT_NAME")"

# If BASE_REF wasn't passed as a CLI arg, default to CURRENT_BRANCH or HEAD
if [ -z "$BASE_REF" ]; then
    BASE_REF="$(git branch --show-current 2>/dev/null || echo "HEAD")"
fi


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
        # Confirmation if creating a brand new branch & worktree
        if [ "$AUTO_CONFIRM" != "yes" ]; then
            echo -ne "${BOLD}Create new worktree and branch '${CYAN}${WT_NAME}${RESET}${BOLD}' from ${YELLOW}${BASE_REF}${RESET}${BOLD}? [Y/n]: ${RESET}"
            read -r CONFIRM_CREATE
            if [[ -n "$CONFIRM_CREATE" && ! "$CONFIRM_CREATE" =~ ^[Yy]$ ]]; then
                echo -e "${DIM}Aborted.${RESET}"
                exit 0
            fi
        fi
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
