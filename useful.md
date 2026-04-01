# Backup hyprconfigs
cp -r ~/.config/hypr ~/.config/hypr_backup_$(date +%F)

# Backup spicetify
spicetify backup apply

# Fix monitor flicker, disable "Variable Refresh Rate" (VRR) / GSync

misc {
    vrr = 0 
}

# make Hyprland vibrant
~/.config/hypr/shaders/vibrance.frag

# Use DE layout in steam overlay
env = XKB_DEFAULT_LAYOUT,de
sudo localectl set-x11-keymap de

# Stretch CS2
gamescope -w 2560 -h 1440 -W 3440 -H 1440 -r 100 -f -S stretch --force-grab-cursor --mangoapp -- %command%

# Fix CS2 Gamesound cut out
Set Enable Game Audio in Background to enabled in the game's settings, or you might encounter random audio cutouts, if you still encounter them just change audio output to some other one and change it back to the one you're using.
