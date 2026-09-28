-- Only differences from hyprland/env.lua -- this file is loaded in ADDITION to,
-- not instead of, the original. Anything not specified here continues to be loaded
-- from hyprland/env.lua and remains automatically up to date.
--
-- Note: hyprland/general.lua sets input.kb_layout and is loaded afterwards.
hl.env("XKB_DEFAULT_LAYOUT", "de")

-- Skip upstream hyprland/keybinds.lua since custom/keybinds.lua provides the full keybind configuration
if is_file_exists(HOME .. "/.config/hypr/custom/keybinds.lua") then
    package.loaded["hyprland.keybinds"] = true
end
