-- =============================================================================
-- Custom Keybinds & Differences
-- =============================================================================
-- This file contains ONLY custom keybind overrides and additions.
-- All ~350 default keybinds (workspaces, volume, brightness, screenshots,
-- window management) are loaded automatically from hyprland/keybinds.lua.
-- =============================================================================

require("hyprland.lib")
require("hyprland.variables")
if is_file_exists and is_file_exists(HOME .. "/.config/hypr/custom/variables.lua") then
    require("custom.variables")
end

-- Helper to safely unbind a key (uses hl.unbind with fallback to hyprctl unbind)
local function safe_unbind(key)
    if hl and hl.unbind then
        pcall(function() hl.unbind(key) end)
    end
    local mods, k = key:match("^(.-)%s*%+%s*([^%+]+)$")
    if mods and k then
        local hypr_mods = mods:gsub("%s*%+%s*", " ")
        pcall(function() os.execute("hyprctl keyword unbind '" .. hypr_mods .. ", " .. k .. "' >/dev/null 2>&1") end)
    end
end

-- 1. Unbind upstream defaults that we want to remap
safe_unbind("SUPER + Q")         -- Default was: close window
safe_unbind("SUPER + C")         -- Default was: code editor
safe_unbind("SUPER + K")         -- Default was: on-screen keyboard
safe_unbind("SUPER + Slash")     -- Default was: cheatsheet
safe_unbind("SUPER + SHIFT + C") -- Default was: color picker
safe_unbind("SUPER + SHIFT + P") -- Default was: media play/pause
safe_unbind("SUPER + ALT + M")   -- Default was: mic mute
safe_unbind("SUPER + R")         -- Unbind any previous mapping for R

-- 2. Windows & Application Launchers
hl.bind("SUPER + C", hl.dsp.window.close(), { description = "Window: Close" })
hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal), { description = "App: Terminal" })
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal), { description = "App: Terminal" })
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal), { description = "App: Terminal" })
hl.bind("SUPER + W", hl.dsp.exec_cmd(browser), { description = "App: Browser" })
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager), { description = "App: File manager" })

-- 3. Utilities & System Overrides
hl.bind("SUPER + R", hl.dsp.exec_cmd("hyprvoice toggle"), { description = "App: Toggle hyprvoice" })
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Utilities: Pick color #RRGGBB >> clipboard" })
hl.bind("SUPER + K", hl.dsp.global("quickshell:cheatsheetToggle"), { description = "Shell: Toggle cheatsheet" })
hl.bind("code:49", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true, description = "Misc: Toggle mic" })
hl.bind("PRINT", hl.dsp.global("quickshell:regionScreenshot"), { description = "Utilities: Screen snip" })
