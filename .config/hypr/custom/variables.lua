-- Only the two modified app lists. terminal, codeEditor, officeSoftware,
-- textEditor, volumeMixer, settingsApp, taskManager, and workspaceGroupSize
-- continue to be loaded from hyprland/variables.lua and remain up to date.

-- Prefer nautilus over dolphin
fileManager =
"~/.config/hypr/hyprland/scripts/launch_first_available.sh 'nautilus' 'dolphin' 'nemo' 'thunar' 'kitty -1 fish -c yazi'"

-- Added helium-browser
browser =
"~/.config/hypr/hyprland/scripts/launch_first_available.sh 'google-chrome-stable' 'zen-browser' 'firefox' 'helium-browser' 'brave' 'chromium' 'microsoft-edge-stable' 'opera' 'librewolf'"
