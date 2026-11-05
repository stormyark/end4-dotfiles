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
UPDATE_UPSTREAM=1
SKIP_PULL=0
USE_COPY=0
AUTO_YES=0
CLEAN=0

show_help() {
    cat <<EOF
Usage: $0 [options]

Options:
  -q, --quick, --no-upstream, --skip-upstream
                      Skip updating upstream dots-hyprland (~/.cache/dots-hyprland).
                      Only restores/updates custom modifications from GitHub.
  -f, --full, -u, --update-upstream
                      Update upstream dots-hyprland (~/.cache/dots-hyprland)
                      via 'git stash && git pull && ./setup install' FIRST,
                      then restore custom modifications from GitHub (enabled by default).
  -c, --clean, --fresh
                      Force a clean reset to origin/$DEFAULT_BRANCH (discards local
                      changes and untracked files, like a fresh clone).
  --no-pull           Skip git pull from GitHub (use local dotfiles repo as-is)
  --copy              Copy files instead of symlinking (stow/ln)
  -y, --yes           Assume yes for all prompts
  -h, --help          Show this help message

Workflows:
  1. Default update & restore (updates upstream dots-hyprland + applies custom mods):
     $0

  2. Fast restore only (skip upstream dots-hyprland, just sync custom mods):
     $0 --quick  (or $0 --no-upstream)

  3. Clean force reset (discards local changes, pulls latest from GitHub):
     $0 --clean

EOF
    exit 0
}

# Parse options
ORIG_ARGS=("$@")
while [[ $# -gt 0 ]]; do
    case "$1" in
        -q|--quick|--no-upstream|--skip-upstream) UPDATE_UPSTREAM=0; shift;;
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

# 1. Locate Dotfiles Repository (resolve symlinks first so ~/.config/scripts/restore-dotfiles.sh finds the repo)
SCRIPT_REAL_INIT="$(realpath "${BASH_SOURCE[0]}" 2>/dev/null || readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_REAL_INIT")" && pwd)"
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

# 2. Step: Pull latest modifications from GitHub
if (( SKIP_PULL == 0 )); then
    echo -e "\n${STY_BLUE}==> Pulling latest modifications from GitHub...${STY_RST}"
    if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
        cd "$DOTFILES_DIR"

        CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$DEFAULT_BRANCH")"
        if [[ "$CURRENT_BRANCH" == "HEAD" || -z "$CURRENT_BRANCH" ]]; then
            CURRENT_BRANCH="$DEFAULT_BRANCH"
        fi

        # Fetch first so local and remote state can be compared and reported
        if ! git fetch origin "$CURRENT_BRANCH"; then
            echo -e "${STY_YELLOW}Warning: git fetch failed (network?). Continuing with local files.${STY_RST}"
        fi

        LOCAL_REV="$(git rev-parse --short HEAD)"
        REMOTE_REV="$(git rev-parse --short "origin/$CURRENT_BRANCH" 2>/dev/null || echo "unknown")"
        echo -e "Local commit:  ${STY_CYAN}$(git log -1 --format='%h %s' HEAD)${STY_RST}"
        echo -e "GitHub commit: ${STY_CYAN}$(git log -1 --format='%h %s' "origin/$CURRENT_BRANCH" 2>/dev/null || echo unknown)${STY_RST}"

        # Restore any tracked files that were accidentally deleted in the working tree
        if [[ -n "$(git ls-files --deleted)" ]]; then
            echo -e "${STY_YELLOW}Restoring missing tracked files in $DOTFILES_DIR...${STY_RST}"
            git checkout HEAD -- $(git ls-files --deleted) 2>/dev/null || git checkout HEAD -- .
        fi

        # Uncommitted local modifications (only modified files, not deletions)
        STASHED=0
        if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
            if (( CLEAN == 1 )); then
                echo -e "${STY_YELLOW}Discarding local modifications (--clean):${STY_RST}"
                git status --short --untracked-files=no
            else
                STASH_MSG="Auto-stashed by restore-dotfiles $(date +%Y-%m-%d_%H-%M-%S)"
                echo -e "${STY_YELLOW}Local modifications found in $DOTFILES_DIR (stashing before pull):${STY_RST}"
                git status --short --untracked-files=no
                git stash push -m "$STASH_MSG" >/dev/null
                STASHED=1
            fi
        fi

        RESTART_NEEDED=0
        if (( CLEAN == 1 )); then
            echo -e "${STY_YELLOW}Force-resetting repository to origin/${CURRENT_BRANCH}...${STY_RST}"
            git reset --hard "origin/$CURRENT_BRANCH"
            git clean -fd
            echo -e "${STY_GREEN}Repository hard-reset to ${REMOTE_REV}.${STY_RST}"
        elif [[ "$REMOTE_REV" == "unknown" ]]; then
            echo -e "${STY_YELLOW}Remote branch unknown. Continuing with local files.${STY_RST}"
        else
            AHEAD="$(git rev-list --count "origin/$CURRENT_BRANCH..HEAD")"
            BEHIND="$(git rev-list --count "HEAD..origin/$CURRENT_BRANCH")"
            if (( BEHIND == 0 && AHEAD == 0 )); then
                echo -e "${STY_GREEN}Already on the latest GitHub commit (${LOCAL_REV}). Nothing new to pull.${STY_RST}"
            elif (( AHEAD == 0 )); then
                echo -e "Pulling ${STY_CYAN}${BEHIND}${STY_RST} new commit(s) from GitHub:"
                git log --oneline "HEAD..origin/$CURRENT_BRANCH"
                if git merge --ff-only "origin/$CURRENT_BRANCH" >/dev/null; then
                    NEW_REV="$(git rev-parse --short HEAD)"
                    echo -e "${STY_GREEN}Updated ${LOCAL_REV} -> ${NEW_REV}.${STY_RST}"

                    if git diff --name-only "$LOCAL_REV" "$NEW_REV" | grep -q "restore-dotfiles.sh"; then
                        RESTART_NEEDED=1
                    fi
                fi
            else
                echo -e "${STY_RED}Local branch has ${AHEAD} commit(s) not on GitHub (behind by ${BEHIND}).${STY_RST}"
                echo -e "${STY_RED}Not pulling automatically. Push them, or run with --clean to discard them.${STY_RST}"
            fi
        fi

        if (( STASHED == 1 && CLEAN == 0 )); then
            if git stash pop --quiet 2>/dev/null; then
                echo -e "${STY_GREEN}Re-applied your local uncommitted modifications on top of latest commit.${STY_RST}"
            else
                git checkout --theirs . 2>/dev/null || true
                git reset HEAD --quiet 2>/dev/null || true
                git checkout HEAD -- . 2>/dev/null || true
                echo -e "${STY_YELLOW}Local modifications conflicted with GitHub changes and remain safely in git stash.${STY_RST}"
                echo -e "${STY_YELLOW}Inspect or restore them with: git -C \"$DOTFILES_DIR\" stash pop${STY_RST}"
            fi
        fi

        if (( RESTART_NEEDED == 1 )); then
            SCRIPT_REAL="$DOTFILES_DIR/.config/scripts/restore-dotfiles.sh"
            if [[ -f "$SCRIPT_REAL" ]]; then
                echo -e "${STY_CYAN}Script was updated from GitHub. Restarting with updated version...${STY_RST}\n"
                exec bash "$SCRIPT_REAL" --no-pull "${ORIG_ARGS[@]}"
            fi
        fi
    else
        echo -e "${STY_YELLOW}$DOTFILES_DIR is not a git repository. Skipping git pull.${STY_RST}"
    fi
else
    echo -e "\n${STY_YELLOW}==> Skipping git pull (--no-pull flag set).${STY_RST}"
fi

# Ensure all tracked files exist in DOTFILES_DIR before proceeding
if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    if [[ -n "$(git -C "$DOTFILES_DIR" ls-files --deleted)" ]]; then
        git -C "$DOTFILES_DIR" checkout HEAD -- . 2>/dev/null || true
    fi
fi

# 3. Step: Update Upstream dots-hyprland (enabled by default)
if (( UPDATE_UPSTREAM == 1 )); then
    UPSTREAM_DIR="$HOME/.cache/dots-hyprland"
    echo -e "\n${STY_BLUE}==> Updating upstream dots-hyprland ($UPSTREAM_DIR)...${STY_RST}"
    if [[ -d "$UPSTREAM_DIR" ]]; then
        (
            cd "$UPSTREAM_DIR"
            echo -e "${STY_CYAN}Running in $UPSTREAM_DIR: git stash && git pull && ./setup install${STY_RST}"
            git stash || true
            git pull || true
            ./setup install
        )
        # In case './setup install' overwrote any tracked files through existing symlinks, restore DOTFILES_DIR
        if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
            git -C "$DOTFILES_DIR" checkout HEAD -- . 2>/dev/null || true
        fi
        echo -e "${STY_GREEN}Upstream dots-hyprland update completed!${STY_RST}"
    else
        echo -e "${STY_YELLOW}Upstream directory $UPSTREAM_DIR does not exist. Skipping upstream update.${STY_RST}"
    fi
else
    echo -e "\n${STY_YELLOW}==> Skipping upstream update (--no-upstream / --quick flag set).${STY_RST}"
fi

# 4. Step: Backup clashing target files before restoring
BACKUP_DIR="$HOME/.cache/dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
echo -e "\n${STY_BLUE}==> Preparing target files (Backup dir: $BACKUP_DIR)...${STY_RST}"

# Files and directories to ignore when restoring to $HOME
# Note: .config/hypr/hyprland is managed by upstream dots-hyprland and Quickshell at runtime
# (e.g. colors.lua, shellOverrides/main.lua) and must NOT be symlinked into the git repo.
IGNORE_LIST=(
    ".git"
    ".gitattributes"
    ".gitignore"
    ".stow-local-ignore"
    ".config/hypr/hyprland"
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

# Find all tracked files in DOTFILES_DIR (fallback to find if not a git repo)
if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    mapfile -t REPO_FILES < <(git -C "$DOTFILES_DIR" ls-files)
else
    mapfile -t REPO_FILES < <(cd "$DOTFILES_DIR" && find . -mindepth 1 -type f)
fi

DOTFILES_REAL="$(realpath "$DOTFILES_DIR" 2>/dev/null || echo "$DOTFILES_DIR")"

# Unfold any directory symlinks in $HOME that point inside DOTFILES_DIR (created by older stow runs without --no-folding)
# CRITICAL: Removing a folded directory symlink (rm "$dir") prevents 'rm -f "$target"' from deleting files inside DOTFILES_DIR!
for f in "${REPO_FILES[@]}"; do
    rel="${f#./}"
    if is_ignored "$rel"; then
        continue
    fi
    parent_rel="$(dirname "$rel")"
    while [[ "$parent_rel" != "." && "$parent_rel" != "/" ]]; do
        target_dir="$HOME/$parent_rel"
        if [[ -L "$target_dir" ]]; then
            dir_real="$(realpath "$target_dir" 2>/dev/null || true)"
            if [[ -n "$dir_real" && "$dir_real" == "$DOTFILES_REAL"* ]]; then
                echo -e "${STY_CYAN}Unfolding directory symlink: $target_dir${STY_RST}"
                rm "$target_dir"
                mkdir -p "$target_dir"
            fi
        fi
        parent_rel="$(dirname "$parent_rel")"
    done
done

backed_up_count=0
for f in "${REPO_FILES[@]}"; do
    rel="${f#./}"
    if is_ignored "$rel"; then
        continue
    fi

    target="$HOME/$rel"
    # If target exists and is a regular file or symlink
    if [[ -e "$target" || -L "$target" ]]; then
        # CRITICAL: Check realpath regardless of whether $target itself or a parent dir is a symlink!
        # Never delete $target if it resolves to the file inside $DOTFILES_DIR!
        target_real="$(realpath "$target" 2>/dev/null || true)"
        source_real="$(realpath "$DOTFILES_DIR/$rel" 2>/dev/null || true)"
        if [[ -n "$target_real" && -n "$source_real" && "$target_real" == "$source_real" ]]; then
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
    echo -e "${STY_CYAN}Using GNU Stow (--no-folding) to link dotfiles...${STY_RST}"
    if ! ( cd "$DOTFILES_DIR" && stow --no-folding -v -R -d "$DOTFILES_DIR" -t "$HOME" . ); then
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
    for shader in "$DOTFILES_DIR/.config/hypr/shaders/"*; do
        [[ -f "$shader" ]] || continue
        target_shader="$HOME/.config/hypr/shaders/$(basename "$shader")"
        if [[ "$(realpath "$shader" 2>/dev/null || true)" != "$(realpath "$target_shader" 2>/dev/null || true)" ]]; then
            cp -f "$shader" "$target_shader" 2>/dev/null || true
        fi
    done
fi

# Post-deploy: Ensure ~/.config/hypr/hyprland contains real upstream files (not symlinks into DOTFILES_DIR)
# This prevents Quickshell runtime writes (colors.lua, shellOverrides) from dirtying the git repo
# and preserves upstream updates from ~/.cache/dots-hyprland.
if [[ -d "$DOTFILES_DIR/.config/hypr/hyprland" ]]; then
    if [[ -L "$HOME/.config/hypr/hyprland" ]]; then
        rm "$HOME/.config/hypr/hyprland"
        mkdir -p "$HOME/.config/hypr/hyprland"
    fi
    UPSTREAM_HYPRLAND_DIR="$HOME/.cache/dots-hyprland/dots/.config/hypr/hyprland"
    while IFS= read -r -d '' src_file; do
        rel_hypr="${src_file#"$DOTFILES_DIR/.config/hypr/hyprland/"}"
        target_hypr="$HOME/.config/hypr/hyprland/$rel_hypr"
        target_hypr_dir="$(dirname "$target_hypr")"
        if [[ -L "$target_hypr_dir" ]]; then
            rm "$target_hypr_dir"
        fi
        mkdir -p "$target_hypr_dir"

        # If target_hypr is a symlink (from old stow runs) or missing, materialize it as a regular file
        if [[ -L "$target_hypr" || ! -e "$target_hypr" ]]; then
            rm -f "$target_hypr"
            if [[ -f "$UPSTREAM_HYPRLAND_DIR/$rel_hypr" ]]; then
                cp -f "$UPSTREAM_HYPRLAND_DIR/$rel_hypr" "$target_hypr"
            else
                cp -f "$src_file" "$target_hypr"
            fi
        fi
    done < <(find "$DOTFILES_DIR/.config/hypr/hyprland" -type f -print0)
fi

# Clean legacy duplicate autostarts/overrides from ~/.config/hypr/hyprland/ if present
for basefile in env.lua execs.lua general.lua variables.lua; do
    target_base="$HOME/.config/hypr/hyprland/$basefile"
    source_base="$DOTFILES_DIR/.config/hypr/hyprland/$basefile"
    if [[ -f "$target_base" && -f "$source_base" && ! -L "$target_base" ]]; then
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
