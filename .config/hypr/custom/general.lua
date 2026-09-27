-- Only differences from hyprland/general.lua. hl.config merges nested tables
-- (e.g. hyprland/colors.lua sets only general.col.*, preserving the rest of general.lua),
-- so specifying only the modified keys is sufficient.

-- MONITOR CONFIG
-- Commented out by preference:
-- hl.monitor({
--     output = "",
--     mode = "3440x1440@100",
--     position = "3440x0",
--     scale = 1
-- })

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1
})

-- GESTURES CONFIG:
-- 3 fingers: Workspace swipe
-- 4 fingers: Move and Fullscreen
hl.gesture({
    fingers = 4,
    direction = "swipe",
    action = "move"
})
hl.gesture({
    fingers = 4,
    direction = "pinch",
    action = "fullscreen"
})
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
hl.gesture({
    fingers = 3,
    direction = "up",
    action = function()
        hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesToggle"))
    end
})
hl.gesture({
    fingers = 3,
    direction = "down",
    action = function()
        hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesToggle"))
    end
})

local homeDir = HOME or os.getenv("HOME") or ""
local shaderPath = homeDir .. "/.config/hypr/shaders/vibrance.frag"

local decorationConfig = {
    active_opacity = 0.975,
    inactive_opacity = 0.97,
}

-- Hyprland's shader parser requires an absolute path rather than tilde '~'.
-- Check if the shader file exists before applying.
if is_file_exists and is_file_exists(shaderPath) then
    decorationConfig.screen_shader = shaderPath
else
    local f = io.open(shaderPath, "r")
    if f then
        io.close(f)
        decorationConfig.screen_shader = shaderPath
    end
end

hl.config({
    general = { gaps_in = 2 },
    decoration = decorationConfig,
    input = { kb_layout = "de" }
})
