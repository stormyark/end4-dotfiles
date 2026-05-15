# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end
    
    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    if test "$TERM" != "linux"
        alias ls 'eza --icons'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end
    alias ll 'ls -Al'
    alias lst 'lsd -a --tree -I .git'
    alias llt 'lsd -ahl --tree -I .git'
    alias ff 'fastfetch'
    alias update 'bash ~/.config/scripts/sysmaintenance.sh'
    alias copy 'wl-copy <'
    alias fixgpu 'killall -9 lmstudio'
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/stormy/.lmstudio/bin
# End of LM Studio CLI section