#!/usr/bin/env bash
# ==============================================================================
# Installer for omp-wt (Linux, macOS, Meta Quest Termux)
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="${SCRIPT_DIR}/omp-wt.sh"

# Install into a user-owned directory. Never require sudo.
if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX/bin" ]; then
    # Termux on Android / Meta Quest
    TARGET_DIR="$PREFIX/bin"
else
    TARGET_DIR="$HOME/.local/bin"
fi

mkdir -p "$TARGET_DIR"
TARGET_FILE="${TARGET_DIR}/omp-wt"

echo "Installing omp-wt to ${TARGET_FILE}..."
cp "$SOURCE_FILE" "$TARGET_FILE"
chmod +x "$TARGET_FILE"

# Detect shell startup file (macOS uses Zsh by default; Bash login shells read .bash_profile)
DETECTED_SHELL="$(basename "${SHELL:-}")"
if [ -z "$DETECTED_SHELL" ] && [ "$(uname -s)" = "Darwin" ]; then
    DETECTED_SHELL="zsh"
fi

case "$DETECTED_SHELL" in
    zsh)
        SHELL_CONFIG="${ZDOTDIR:-$HOME}/.zshrc"
        ;;
    bash)
        if [ "$(uname -s)" = "Darwin" ]; then
            if [ -f "$HOME/.bash_profile" ]; then
                SHELL_CONFIG="$HOME/.bash_profile"
            else
                SHELL_CONFIG="$HOME/.profile"
            fi
        else
            SHELL_CONFIG="$HOME/.bashrc"
        fi
        ;;
    *)
        if [ "$(uname -s)" = "Darwin" ]; then
            SHELL_CONFIG="${ZDOTDIR:-$HOME}/.zshrc"
        else
            SHELL_CONFIG="$HOME/.profile"
        fi
        ;;
esac

# Add to PATH if not already present
if [[ ":$PATH:" != *":${TARGET_DIR}:"* ]] && [ -n "$SHELL_CONFIG" ]; then
    PATH_LINE="export PATH=\"${TARGET_DIR}:\$PATH\""
    if ! grep -qF "$TARGET_DIR" "$SHELL_CONFIG" 2>/dev/null; then
        printf '\n# omp-wt PATH\n%s\n' "$PATH_LINE" >> "$SHELL_CONFIG"
        echo "Added ${TARGET_DIR} to PATH in ${SHELL_CONFIG}."
        echo "Open a new terminal, or run: source \"${SHELL_CONFIG}\""
    fi
fi

echo "✓ Successfully installed omp-wt!"
echo ""
echo "Try running:"
echo "  omp-wt guide      # Read the beginner's visual guide"
echo "  omp-wt list       # List worktrees in your current git repo"
echo "  omp-wt            # Launch interactive wizard"
