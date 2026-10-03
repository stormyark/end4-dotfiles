-- =============================================================================
-- Personal Custom Keybinds & Overview
-- =============================================================================
-- All your personal keybind customizations are organized here.
-- To add or modify keybinds, simply edit this file.
-- It is automatically loaded by ~/.config/hypr/custom/keybinds.lua.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Window Management & Application Launchers
-- -----------------------------------------------------------------------------
-- Close active window (changed from SUPER+Q to SUPER+C)
hl.bind("SUPER + C", hl.dsp.window.close(), { description = "Window: Close" })

-- Terminal (SUPER+Q in addition to SUPER+Return and SUPER+T)
hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal), { description = "App: Terminal" })

-- Hyprvoice toggle
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("hyprvoice toggle"), { description = "App: Toggle hyprvoice" })

-- Maximize window
hl.bind("ALT + RETURN", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Window: Maximize" })

-- -----------------------------------------------------------------------------
-- Shell Utilities & Quick Toggles
-- -----------------------------------------------------------------------------
-- Cheatsheet (changed from SUPER+Slash to SUPER+K)
hl.bind("SUPER + K", hl.dsp.global("quickshell:cheatsheetToggle"), { description = "Shell: Toggle cheatsheet" })

-- Color picker (changed from SUPER+SHIFT+C to SUPER+SHIFT+P)
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Utilities: Pick color #RRGGBB >> clipboard" })

-- Region screenshot (Screen snip)
hl.bind("PRINT", hl.dsp.global("quickshell:regionScreenshot"), { description = "Utilities: Screen snip" })

-- -----------------------------------------------------------------------------
-- Scratchpad
-- -----------------------------------------------------------------------------
-- Move active window to scratchpad
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special", follow = false }), { description = "Window: Send to scratchpad" })

-- Toggle scratchpad visibility
hl.bind("CTRL + SUPER + S", hl.dsp.workspace.toggle_special("special"), { description = "Workspace: Toggle scratchpad" })
