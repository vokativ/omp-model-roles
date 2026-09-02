#!/usr/bin/env bash
# ==============================================================================
# Installer for omp-wt (Linux, macOS, Meta Quest Termux)
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="${SCRIPT_DIR}/omp-wt.sh"

# Determine target bin directory
if [ -n "$PREFIX" ] && [ -d "$PREFIX/bin" ]; then
    # Termux on Android / Meta Quest
    TARGET_DIR="$PREFIX/bin"
elif [ -d "$HOME/.local/bin" ]; then
    TARGET_DIR="$HOME/.local/bin"
else
    TARGET_DIR="/usr/local/bin"
fi

mkdir -p "$TARGET_DIR" 2>/dev/null || sudo mkdir -p "$TARGET_DIR"
TARGET_FILE="${TARGET_DIR}/omp-wt"

echo "Installing omp-wt to ${TARGET_FILE}..."
if [ -w "$TARGET_DIR" ]; then
    cp "$SOURCE_FILE" "$TARGET_FILE"
    chmod +x "$TARGET_FILE"
else
    sudo cp "$SOURCE_FILE" "$TARGET_FILE"
    sudo chmod +x "$TARGET_FILE"
fi

echo "✓ Successfully installed omp-wt!"
echo ""
echo "Try running:"
echo "  omp-wt guide      # Read the beginner's visual guide"
echo "  omp-wt list       # List worktrees in your current git repo"
echo "  omp-wt            # Launch interactive wizard"
