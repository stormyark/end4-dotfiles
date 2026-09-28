# Custom Commands & Functions for end4-dotfiles
# Located in conf.d/ to be preserved across upstream dots-hyprland updates.

function __run_dotfiles_script
    set -l script_name $argv[1]
    set -e argv[1]

    set -l candidates \
        "$HOME/.config/scripts/$script_name" \
        "$HOME/dotfiles/.config/scripts/$script_name" \
        "$HOME/dotfiles/$script_name" \
        "$HOME/Projects/end4-dotfiles-master/.config/scripts/$script_name"

    for candidate in $candidates
        if test -f "$candidate"
            bash "$candidate" $argv
            return $status
        end
    end

    # If restore-dotfiles.sh is missing everywhere, clone from GitHub automatically
    if test "$script_name" = "restore-dotfiles.sh"
        echo "restore-dotfiles.sh not found. Auto-cloning from GitHub..."
        git clone https://github.com/stormyark/end4-dotfiles.git "$HOME/dotfiles"
        if test -f "$HOME/dotfiles/.config/scripts/restore-dotfiles.sh"
            bash "$HOME/dotfiles/.config/scripts/restore-dotfiles.sh" $argv
            return $status
        end
    end

    echo "Error: $script_name could not be found." >&2
    return 1
end

function restore-dots
    __run_dotfiles_script restore-dotfiles.sh $argv
end

function clean-dots
    __run_dotfiles_script restore-dotfiles.sh --clean $argv
end

function update-dots
    __run_dotfiles_script restore-dotfiles.sh --full $argv
end

function updates-dots
    __run_dotfiles_script restore-dotfiles.sh --full $argv
end

function update
    __run_dotfiles_script sysmaintenance.sh $argv
end
