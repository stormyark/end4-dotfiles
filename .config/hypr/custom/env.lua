-- Only differences from hyprland/env.lua -- this file is loaded in ADDITION to,
-- not instead of, the original. Anything not specified here continues to be loaded
-- from hyprland/env.lua and remains automatically up to date.
--
-- Note: hyprland/general.lua sets input.kb_layout and is loaded afterwards.
hl.env("XKB_DEFAULT_LAYOUT", "de")

-- =============================================================================
-- Keybind Interception Hook
-- =============================================================================
-- In Hyprland, `hl.bind` is strictly additive. Calling hl.bind for an already
-- bound key combination registers multiple dispatchers on that key, causing
-- duplicate executions (e.g. launching two file managers or closing + launching).
-- Because hyprland.lua loads `custom/env.lua` BEFORE `hyprland/keybinds.lua` and
-- `custom/keybinds.lua` AFTER `hyprland/keybinds.lua`, we intercept `hl.bind` here.
-- Any key configured or unbound in `custom/keybinds.lua` is suppressed while
-- `hyprland/keybinds.lua` executes.
-- =============================================================================

local raw_hl_bind = _G.__raw_hl_bind or hl.bind
_G.__raw_hl_bind = raw_hl_bind

local function normalize_key(k)
    if type(k) ~= "string" then return tostring(k) end
    local parts = {}
    for part in k:gmatch("[^%+]+") do
        local trimmed = part:match("^%s*(.-)%s*$"):upper()
        if trimmed ~= "" then
            table.insert(parts, trimmed)
        end
    end
    if #parts == 0 then return "" end
    local key = table.remove(parts)
    table.sort(parts)
    table.insert(parts, key)
    return table.concat(parts, "+")
end

local suppressed_keys = {
    [normalize_key("SUPER + Q")] = true,
    [normalize_key("SUPER + C")] = true,
    [normalize_key("SUPER + Return")] = true,
    [normalize_key("SUPER + T")] = true,
    [normalize_key("SUPER + W")] = true,
    [normalize_key("SUPER + E")] = true,
    [normalize_key("SUPER + R")] = true,
    [normalize_key("SUPER + K")] = true,
    [normalize_key("SUPER + Slash")] = true,
    [normalize_key("SUPER + SHIFT + C")] = true,
    [normalize_key("SUPER + SHIFT + P")] = true,
    [normalize_key("SUPER + ALT + M")] = true,
    [normalize_key("Print")] = true,
    [normalize_key("code:49")] = true,
}

-- Dynamically scan custom/keybinds.lua to automatically suppress any custom key
local home = HOME or os.getenv("HOME") or ""
local custom_file = home .. "/.config/hypr/custom/keybinds.lua"
local f = io.open(custom_file, "r")
if not f then
    f = io.open(home .. "/dotfiles/.config/hypr/custom/keybinds.lua", "r")
end
if f then
    for line in f:lines() do
        if not line:match("^%s*%-%-") then
            local key = line:match('hl%.bind%s*%(%s*["\']([^"\']+)["\']') or
                        line:match('hl%.unbind%s*%(%s*["\']([^"\']+)["\']') or
                        line:match('unbind%s*%(%s*["\']([^"\']+)["\']')
            if key then
                suppressed_keys[normalize_key(key)] = true
            end
        end
    end
    f:close()
end

-- Filter upstream keybinds during hyprland/keybinds.lua execution
hl.bind = function(key, dsp, opts)
    if suppressed_keys[normalize_key(key)] then
        return
    end
    return raw_hl_bind(key, dsp, opts)
end

-- Safe unbind helper in case any script calls hl.unbind
hl.unbind = hl.unbind or function(key) end
