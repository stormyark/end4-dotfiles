#!/usr/bin/env bash
#
# restore-dotfiles.sh - Restore custom dotfiles & Hyprland modifications
#
# Author: stormy
# GitHub: https://github.com/stormyark/end4-dotfiles
#
# Description:
# Pulls custom dotfiles from GitHub and restores/links configurations
# into ~/.config and $HOME. Fixes broken configurations after system
# updates (pacman -Syu) or dots-hyprland updates (setup install).
#
# Usage:
#   ./restore-dotfiles.sh [options]
#

set -euo pipefail

# ANSI color codes
STY_RED="\033[1;31m"
STY_GREEN="\033[1;32m"
STY_YELLOW="\033[1;33m"
STY_BLUE="\033[1;34m"
STY_CYAN="\033[1;36m"
STY_RST="\033[0m"

# Default settings
REPO_URL="https://github.com/stormyark/end4-dotfiles.git"
DEFAULT_BRANCH="master"
UPDATE_UPSTREAM=0
SKIP_PULL=0
USE_COPY=0
AUTO_YES=0
CLEAN=0

show_help() {
    cat <<EOF
Usage: $0 [options]

Options:
  -f, --full, -u, --update-upstream
                      Update upstream dots-hyprland (~/.cache/dots-hyprland)
                      via 'git stash && git pull && ./setup install' FIRST,
                      then restore custom modifications from GitHub.
  -c, --clean, --fresh
                      Force a clean reset to origin/$DEFAULT_BRANCH (discards local
                      changes and untracked files, like a fresh clone).
  --no-pull           Skip git pull from GitHub (use local dotfiles repo as-is)
  --copy              Copy files instead of symlinking (stow/ln)
  -y, --yes           Assume yes for all prompts
  -h, --help          Show this help message

Workflows:
  1. Just restore/update custom mods:
     $0

  2. Clean force reset (discards local changes, pulls latest from GitHub):
     $0 --clean

  3. Full repair (dots-hyprland update + restore custom mods in one step):
     $0 --full

EOF
    exit 0
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--full|-u|--update-upstream) UPDATE_UPSTREAM=1; shift;;
        -c|--clean|--fresh) CLEAN=1; shift;;
        --no-pull) SKIP_PULL=1; shift;;
        --copy) USE_COPY=1; shift;;
        -y|--yes) AUTO_YES=1; shift;;
        -h|--help) show_help;;
        --) shift; break;;
        *) echo -e "${STY_RED}Unknown option: $1${STY_RST}"; show_help;;
    esac
done

echo -e "${STY_CYAN}==========================================${STY_RST}"
echo -e "${STY_CYAN}  Custom Dotfiles Restore & Sync Tool     ${STY_RST}"
echo -e "${STY_CYAN}==========================================${STY_RST}"

# 1. Locate Dotfiles Repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR=""

# Check if script is inside a git repository
if git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    DOTFILES_DIR="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
elif [[ -d "$HOME/dotfiles" ]]; then
    DOTFILES_DIR="$HOME/dotfiles"
elif [[ -d "$HOME/Projects/end4-dotfiles-master" ]]; then
    DOTFILES_DIR="$HOME/Projects/end4-dotfiles-master"
else
    DOTFILES_DIR="$HOME/dotfiles"
fi

# If repository directory does not exist, clone it
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "${STY_YELLOW}Dotfiles directory not found at: $DOTFILES_DIR${STY_RST}"
    echo -e "${STY_BLUE}Cloning from $REPO_URL into $DOTFILES_DIR...${STY_RST}"
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

echo -e "${STY_GREEN}Using dotfiles repository:${STY_RST} $DOTFILES_DIR"

# 2. Step: Run Upstream Update First (if requested)
if (( UPDATE_UPSTREAM == 1 )); then
    UPSTREAM_DIR="$HOME/.cache/dots-hyprland"
    echo -e "\n${STY_BLUE}==> Updating upstream dots-hyprland ($UPSTREAM_DIR)...${STY_RST}"
    if [[ -d "$UPSTREAM_DIR" ]]; then
        (
            cd "$UPSTREAM_DIR"
            echo -e "${STY_CYAN}Running: git stash && git pull && ./setup install${STY_RST}"
            git stash || true
            git pull || true
            ./setup install
        )
        echo -e "${STY_GREEN}Upstream dots-hyprland update completed!${STY_RST}"
    else
        echo -e "${STY_RED}Upstream directory $UPSTREAM_DIR does not exist. Skipping upstream update.${STY_RST}"
    fi
fi

# 3. Step: Pull latest modifications from GitHub
if (( SKIP_PULL == 0 )); then
    echo -e "\n${STY_BLUE}==> Pulling latest modifications from GitHub...${STY_RST}"
    if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
        cd "$DOTFILES_DIR"

        # Check for uncommitted local changes
        if ! git diff-index --quiet HEAD -- 2>/dev/null; then
            echo -e "${STY_YELLOW}Uncommitted changes detected in $DOTFILES_DIR.${STY_RST}"
            echo -e "${STY_YELLOW}Stashing local modifications to prevent conflicts...${STY_RST}"
            git stash push -m "Auto-stashed by restore-dotfiles $(date +%Y-%m-%d_%H-%M-%S)"
        fi

        CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$DEFAULT_BRANCH")"
        if [[ "$CURRENT_BRANCH" == "HEAD" || -z "$CURRENT_BRANCH" ]]; then
            CURRENT_BRANCH="$DEFAULT_BRANCH"
        fi

        if (( CLEAN == 1 )); then
            echo -e "${STY_YELLOW}Force-resetting repository to origin/${CURRENT_BRANCH}...${STY_RST}"
            git fetch origin "$CURRENT_BRANCH"
            git reset --hard "origin/$CURRENT_BRANCH"
            git clean -fd
            echo -e "${STY_GREEN}Repository hard-reset to latest origin/${CURRENT_BRANCH}.${STY_RST}"
        else
            echo -e "Pulling branch ${STY_CYAN}${CURRENT_BRANCH}${STY_RST} from origin..."
            if git pull origin "$CURRENT_BRANCH"; then
                echo -e "${STY_GREEN}Successfully updated repository from GitHub.${STY_RST}"
            else
                echo -e "${STY_YELLOW}Warning: git pull failed (network or conflict). Continuing with local files.${STY_RST}"
            fi
        fi
    else
        echo -e "${STY_YELLOW}$DOTFILES_DIR is not a git repository. Skipping git pull.${STY_RST}"
    fi
else
    echo -e "\n${STY_YELLOW}==> Skipping git pull (--no-pull flag set).${STY_RST}"
fi

# 4. Step: Backup clashing target files before restoring
BACKUP_DIR="$HOME/.cache/dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
echo -e "\n${STY_BLUE}==> Preparing target files (Backup dir: $BACKUP_DIR)...${STY_RST}"

# Files and directories to ignore when restoring to $HOME
IGNORE_LIST=(
    ".git"
    ".stow-local-ignore"
    "install.sh"
    "pkglist.txt"
    "README.md"
    "upload.md"
    "useful.md"
)

is_ignored() {
    local rel="$1"
    for item in "${IGNORE_LIST[@]}"; do
        if [[ "$rel" == "$item" || "$rel" == "$item"/* || "$rel" == *"/$item" ]]; then
            return 0
        fi
    done
    if [[ "$rel" == *.md ]]; then
        return 0
    fi
    return 1
}

# Find all files in DOTFILES_DIR
mapfile -t REPO_FILES < <(cd "$DOTFILES_DIR" && find . -mindepth 1 -type f)

backed_up_count=0
for f in "${REPO_FILES[@]}"; do
    rel="${f#./}"
    if is_ignored "$rel"; then
        continue
    fi

    target="$HOME/$rel"
    # If target exists and is a regular file or broken symlink
    if [[ -e "$target" || -L "$target" ]]; then
        # Check if already points to our dotfile
        if [[ -L "$target" ]] && [[ "$(realpath "$target" 2>/dev/null || true)" == "$(realpath "$DOTFILES_DIR/$rel" 2>/dev/null || true)" ]]; then
            continue
        fi

        # Backup existing target file
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        cp -a "$target" "$BACKUP_DIR/$rel"
        backed_up_count=$((backed_up_count + 1))

        # Remove existing target file/symlink so stow or ln can link cleanly without clash
        rm -f "$target"
    fi
done

if (( backed_up_count > 0 )); then
    echo -e "${STY_GREEN}Backed up $backed_up_count existing clashing files to $BACKUP_DIR${STY_RST}"
else
    # Clean empty backup directory if nothing was backed up
    rm -rf "$BACKUP_DIR" 2>/dev/null || true
fi

# 5. Step: Deploy files (Stow or Symlink or Copy)
echo -e "\n${STY_BLUE}==> Deploying custom configuration files...${STY_RST}"

if (( USE_COPY == 1 )); then
    echo -e "${STY_CYAN}Copying files from $DOTFILES_DIR to $HOME...${STY_RST}"
    for f in "${REPO_FILES[@]}"; do
        rel="${f#./}"
        if is_ignored "$rel"; then continue; fi
        target="$HOME/$rel"
        mkdir -p "$(dirname "$target")"
        cp -f "$DOTFILES_DIR/$rel" "$target"
        echo "  Copied: $rel"
    done
elif command -v stow &>/dev/null; then
    echo -e "${STY_CYAN}Using GNU Stow to link dotfiles...${STY_RST}"
    if ! ( cd "$DOTFILES_DIR" && stow -v -R -d "$DOTFILES_DIR" -t "$HOME" . ); then
        echo -e "${STY_YELLOW}GNU Stow encountered an issue. Falling back to direct symlinks (ln -sfn)...${STY_RST}"
        for f in "${REPO_FILES[@]}"; do
            rel="${f#./}"
            if is_ignored "$rel"; then continue; fi
            target="$HOME/$rel"
            mkdir -p "$(dirname "$target")"
            ln -sfn "$DOTFILES_DIR/$rel" "$target"
            echo "  Linked: $rel -> $target"
        done
    fi
else
    echo -e "${STY_YELLOW}GNU Stow not found. Falling back to direct symlinks (ln -s)...${STY_RST}"
    for f in "${REPO_FILES[@]}"; do
        rel="${f#./}"
        if is_ignored "$rel"; then continue; fi
        target="$HOME/$rel"
        mkdir -p "$(dirname "$target")"
        ln -sfn "$DOTFILES_DIR/$rel" "$target"
        echo "  Linked: $rel -> $target"
    done
fi

# Clean root-level documentation symlinks that stow may have linked into $HOME
for junk in upload.md useful.md; do
    if [[ -L "$HOME/$junk" ]]; then
        rm -f "$HOME/$junk"
    fi
done

# Post-deploy: Ensure shaders and clean upstream base configs
if [[ -d "$DOTFILES_DIR/.config/hypr/shaders" ]]; then
    mkdir -p "$HOME/.config/hypr/shaders"
    cp -f "$DOTFILES_DIR/.config/hypr/shaders/"* "$HOME/.config/hypr/shaders/" 2>/dev/null || true
fi

# Clean legacy duplicate autostarts/overrides from ~/.config/hypr/hyprland/ if present
for basefile in env.lua execs.lua general.lua variables.lua; do
    target_base="$HOME/.config/hypr/hyprland/$basefile"
    source_base="$DOTFILES_DIR/.config/hypr/hyprland/$basefile"
    if [[ -f "$target_base" && -f "$source_base" ]]; then
        if grep -q "Autostart Applications" "$target_base" 2>/dev/null || \
           grep -q "screen_shader" "$target_base" 2>/dev/null || \
           grep -q "XKB_DEFAULT_LAYOUT" "$target_base" 2>/dev/null; then
            echo -e "${STY_YELLOW}Cleaning legacy overrides from ~/.config/hypr/hyprland/$basefile...${STY_RST}"
            cp -f "$source_base" "$target_base"
        fi
    fi
done

# Ensure custom keybind files are copied if missing
if [[ -f "$DOTFILES_DIR/.config/hypr/custom/keybinds.lua" && ! -f "$HOME/.config/hypr/custom/keybinds.lua" ]]; then
    mkdir -p "$HOME/.config/hypr/custom"
    cp -f "$DOTFILES_DIR/.config/hypr/custom/keybinds.lua" "$HOME/.config/hypr/custom/keybinds.lua"
fi
if [[ -f "$DOTFILES_DIR/.config/hypr/custom/personal_keybinds.lua" && ! -f "$HOME/.config/hypr/custom/personal_keybinds.lua" ]]; then
    mkdir -p "$HOME/.config/hypr/custom"
    cp -f "$DOTFILES_DIR/.config/hypr/custom/personal_keybinds.lua" "$HOME/.config/hypr/custom/personal_keybinds.lua"
fi

# 6. Step: Ensure executable permissions on scripts
echo -e "\n${STY_BLUE}==> Setting executable permissions on scripts...${STY_RST}"
find "$HOME/.config/scripts" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
find "$HOME/.config/hypr" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
find "$DOTFILES_DIR" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

# 7. Step: Reload Hyprland if running
if pgrep -x "Hyprland" &>/dev/null || command -v hyprctl &>/dev/null; then
    echo -e "\n${STY_BLUE}==> Reloading Hyprland configuration...${STY_RST}"
    if hyprctl reload &>/dev/null; then
        echo -e "${STY_GREEN}Hyprland reloaded successfully!${STY_RST}"
    else
        echo -e "${STY_YELLOW}Hyprland reload command dispatched.${STY_RST}"
    fi
fi

# 8. Step: Desktop Notification
if command -v notify-send &>/dev/null; then
    notify-send -a "Dotfiles" "Configuration Restored" "Custom Hyprland and dotfiles have been restored from GitHub." 2>/dev/null || true
fi

echo -e "\n${STY_GREEN}==========================================${STY_RST}"
echo -e "${STY_GREEN}  Configuration successfully restored!    ${STY_RST}"
echo -e "${STY_GREEN}==========================================${STY_RST}"
