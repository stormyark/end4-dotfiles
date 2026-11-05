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

## Keybinds & Custom Config Architecture

### Why Keybinds are not additive and how we solved it
In `dots-hyprland`, `~/.config/hypr/custom/` is **never** touched by upstream updates (`./setup install` uses `install_dir__ignore_existing` for `custom/`). Most settings (`env.lua`, `execs.lua`, `general.lua`, `variables.lua`) are additive or last-wins.

However, **keybindings are NOT additive**:
1. `hl.bind` only adds key dispatchers (there is no `hl.unbind` in Hyprland's Lua API).
2. If custom keybinds were loaded on top of upstream `hyprland/keybinds.lua`, multiple actions would trigger on the same key combination (e.g. launching two file managers).

**The Solution:**
- `~/.config/hypr/custom/env.lua` is loaded by `hyprland.lua` **before** `hyprland/keybinds.lua`.
- In `custom/env.lua`, setting `package.loaded["hyprland.keybinds"] = true` cleanly tells Lua that keybinds are already handled, skipping upstream defaults.
- `~/.config/hypr/custom/keybinds.lua` loads the base keybinding suite and includes `~/.config/hypr/custom/personal_keybinds.lua`.
- **`~/.config/hypr/custom/personal_keybinds.lua`**: Your clean, dedicated file containing ONLY your personal shortcuts and overrides. You can open and edit this file anytime to add or adjust your keybindings!

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

#### Option A: One-Step Full Update & Restore (Default)
Updates upstream dots-hyprland via `./setup install` AND pulls/restores your GitHub modifications in one command:
```bash
restore-dots
# Or: update-dots
# Or: bash ~/.config/scripts/restore-dotfiles.sh
```

#### Option B: Quick Restore Only (Skip Upstream Update)
If you only want to pull and link your custom modifications from GitHub without running upstream `dots-hyprland` setup:
```bash
quick-dots
# Or: bash ~/.config/scripts/restore-dotfiles.sh --no-upstream
```

*(Note: Thanks to the `custom/` architecture, your custom settings in `~/.config/hypr/custom/` will even remain intact across upstream updates! Running `restore-dots` or `quick-dots` pulls any new changes from GitHub and ensures all shell aliases, scripts, and links are synchronized).*

---

## Helpful Commands
| Command | Action |
|---|---|
| `update` | Run system maintenance (`sysmaintenance.sh`) |
| `restore-dots` / `update-dots` | Full update: update `dots-hyprland` upstream + pull & restore custom mods |
| `quick-dots` | Fast restore: pull & restore custom mods only (`--no-upstream`) |
| `clean-dots` | Force clean reset of local dotfiles repo to GitHub `master` (`--clean`) |
| `fixgpu` | Kill hung LM Studio process (`killall -9 lmstudio`) |
