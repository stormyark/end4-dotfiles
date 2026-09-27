-- Only differences from hyprland/env.lua -- this file is loaded in ADDITION to,
-- not instead of, the original. Anything not specified here continues to be loaded
-- from hyprland/env.lua and remains automatically up to date.
--
-- Note: hyprland/general.lua sets input.kb_layout and is loaded afterwards.
hl.env("XKB_DEFAULT_LAYOUT", "de")

-- =============================================================================
-- Keybind override for dots-hyprland:
-- Because hl.bind is additive and there is no hl.unbind, keybinds are not additive.
-- Any remapping in custom/keybinds.lua would otherwise fire IN ADDITION to
-- hyprland/keybinds.lua (e.g. SUPER+C would close windows AND launch code editor).
--
-- Solution: custom/env.lua is loaded in hyprland.lua BEFORE hyprland/keybinds.lua.
-- Setting package.loaded["hyprland.keybinds"] = true tells Lua that the module
-- is already loaded, skipping upstream keybinds completely.
-- Afterwards, hyprland.lua cleanly loads custom/keybinds.lua with personal keybinds.
-- Because ~/.config/hypr/custom/ is NEVER deleted or modified by upstream updates
-- ('./setup install'), personal keybinds stay active, conflict-free, and persistent!
-- =============================================================================
if is_file_exists(HOME .. "/.config/hypr/custom/keybinds.lua") then
    package.loaded["hyprland.keybinds"] = true
end
