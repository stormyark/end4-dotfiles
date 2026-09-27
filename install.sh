#!/usr/bin/env bash
#
# install.sh - Entry point to install or restore custom dotfiles
#
# Usage:
#   ./install.sh [options]
#   See: ./install.sh --help
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESTORE_SCRIPT="$SCRIPT_DIR/.config/scripts/restore-dotfiles.sh"

if [[ -f "$RESTORE_SCRIPT" ]]; then
    exec bash "$RESTORE_SCRIPT" "$@"
else
    echo "Error: $RESTORE_SCRIPT not found!" >&2
    exit 1
fi
