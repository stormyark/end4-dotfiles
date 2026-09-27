-- Nur die beiden abweichenden Listen. terminal, codeEditor, officeSoftware,
-- textEditor, volumeMixer, settingsApp, taskManager und workspaceGroupSize
-- kommen weiter aus hyprland/variables.lua und bleiben damit aktuell.

-- nautilus vor dolphin
fileManager =
"~/.config/hypr/hyprland/scripts/launch_first_available.sh 'nautilus' 'dolphin' 'nemo' 'thunar' 'kitty -1 fish -c yazi'"

-- helium-browser ergaenzt
browser =
"~/.config/hypr/hyprland/scripts/launch_first_available.sh 'google-chrome-stable' 'zen-browser' 'firefox' 'helium-browser' 'brave' 'chromium' 'microsoft-edge-stable' 'opera' 'librewolf'"
