# My Dotfiles (end4-dotfiles)

This directory contains the dotfiles and modifications for my Arch Linux / CachyOS & [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) setup.

## Requirements

Ensure you have the following installed on your system:

**Git**
```bash
sudo pacman -S git
```

**Stow**
```bash
sudo pacman -S stow
```

## Installation

Clone the repo and run `./install.sh`:
```bash
git clone https://github.com/stormyark/end4-dotfiles dotfiles
cd dotfiles
./install.sh
```

---

## Keybinds & Custom Config

In Hyprland, `hl.bind` is strictly additive (there is no `hl.unbind`). 
- **Application shortcuts** (`SUPER + Return`, `SUPER + E`, `SUPER + W`) use the variables defined in `~/.config/hypr/custom/variables.lua`.
- **New personal keybinds** (such as `SUPER + R` for `hyprvoice toggle`) are placed in `~/.config/hypr/custom/keybinds.lua`.
- **Core keybind modifications** are versioned directly in `.config/hypr/hyprland/keybinds.lua` within this repository and symlinked via GNU Stow.

---

## Workflow & Maintenance

### 1. Regular System Updates
Update system packages, AUR, clean caches, and perform maintenance:
```bash
# Via alias:
update

# Or directly:
bash ~/.config/scripts/sysmaintenance.sh
```

### 2. When Dotfiles Break (After System Updates)
If a system upgrade breaks Hyprland or Quickshell components, update upstream dots-hyprland and restore your custom configuration:

#### Option A: One-Step Full Repair (Recommended)
Updates upstream dots-hyprland via `./setup install` AND pulls/restores your GitHub modifications in one command:
```bash
update-dots
# Or: bash ~/.config/scripts/restore-dotfiles.sh --full
```

#### Option B: Manual Upstream Update + Restore
If you prefer running the official update manually:
```bash
# 1. Official upstream update:
cd ~/.cache/dots-hyprland && git stash && git pull && ./setup install

# 2. Restore custom dotfiles & pull latest GitHub mods:
restore-dots
# Or: bash ~/.config/scripts/restore-dotfiles.sh
```

*(Note: Thanks to the `custom/` architecture, your custom settings in `~/.config/hypr/custom/` will even remain intact before step 2! Step 2 pulls any new changes from GitHub and ensures all shell aliases, scripts, and links are synchronized).*

---

## Helpful Commands
| Command | Action |
|---|---|
| `update` | Run system maintenance (`sysmaintenance.sh`) |
| `restore-dots` | Pull latest mods from GitHub & restore configs |
| `update-dots` | Full repair: update dots-hyprland upstream + restore mods |
| `fixgpu` | Kill hung LM Studio process (`killall -9 lmstudio`) |