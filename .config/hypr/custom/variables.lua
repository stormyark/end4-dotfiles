-- Only modified application launcher variables.
-- terminal, fileManager, and browser use absolute paths to ensure reliable launching.

local homeDir = HOME or os.getenv("HOME") or ""
local launcher = homeDir .. "/.config/hypr/hyprland/scripts/launch_first_available.sh"

-- Terminal (prefer kitty)
terminal = launcher .. " 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm'"

-- File manager (prefer nautilus)
fileManager = launcher .. " 'nautilus' 'dolphin' 'nemo' 'thunar' 'kitty -1 fish -c yazi'"

-- Browser (includes helium-browser)
browser = launcher .. " 'google-chrome-stable' 'zen-browser' 'firefox' 'helium-browser' 'brave' 'chromium' 'microsoft-edge-stable' 'opera' 'librewolf'"
