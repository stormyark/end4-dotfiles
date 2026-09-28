-- =============================================================================
-- Custom Keybinds & Differences
-- =============================================================================
-- This file contains ONLY custom keybind overrides and additions.
-- Matching upstream keys are automatically suppressed during initialization
-- by custom/env.lua so that each key combination triggers exactly once.
-- All ~350 default keybinds (workspaces, volume, brightness, screenshots,
-- window management) are loaded automatically from hyprland/keybinds.lua.
-- =============================================================================

require("hyprland.lib")
require("hyprland.variables")
if is_file_exists and is_file_exists(HOME .. "/.config/hypr/custom/variables.lua") then
    require("custom.variables")
end

-- Restore raw hl.bind to register custom bindings cleanly
if _G.__raw_hl_bind then
    hl.bind = _G.__raw_hl_bind
end
hl.unbind = hl.unbind or function(key) end

-- 1. Upstream keys that are moved or replaced (parsed by custom/env.lua)
hl.unbind("SUPER + Slash")     -- Default cheatsheet moved to SUPER + K
hl.unbind("SUPER + SHIFT + C") -- Default color picker moved to SUPER + SHIFT + P
hl.unbind("SUPER + ALT + M")   -- Default mic mute moved to code:49

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
