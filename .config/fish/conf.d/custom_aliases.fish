# Custom Aliases & Persistent Maintenance Commands for end4-dotfiles
# This file is located in conf.d/ and is therefore preserved across
# dots-hyprland updates (dots-hyprland setup install excludes conf.d).

alias update 'bash ~/.config/scripts/sysmaintenance.sh'
alias restore-dots 'bash ~/.config/scripts/restore-dotfiles.sh'
alias update-dots 'bash ~/.config/scripts/restore-dotfiles.sh --full'
alias updates-dots 'bash ~/.config/scripts/restore-dotfiles.sh --full'
