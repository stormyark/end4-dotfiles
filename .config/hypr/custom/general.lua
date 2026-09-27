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
-- Unset default upstream gestures from hyprland/general.lua to prevent "overshadowed by previous gesture" conflicts:
pcall(function() hl.gesture({ fingers = 3, direction = "swipe", action = "unset" }) end)
pcall(function() hl.gesture({ fingers = 3, direction = "pinch", action = "unset" }) end)
pcall(function() hl.gesture({ fingers = 4, direction = "horizontal", action = "unset" }) end)
pcall(function() hl.gesture({ fingers = 4, direction = "up", action = "unset" }) end)
pcall(function() hl.gesture({ fingers = 4, direction = "down", action = "unset" }) end)

-- Custom gestures:
-- 3 fingers: Workspace swipe and overview toggle
pcall(function()
    hl.gesture({
        fingers = 3,
        direction = "horizontal",
        action = "workspace"
    })
end)
pcall(function()
    hl.gesture({
        fingers = 3,
        direction = "up",
        action = function()
            hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesToggle"))
        end
    })
end)
pcall(function()
    hl.gesture({
        fingers = 3,
        direction = "down",
        action = function()
            hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesToggle"))
        end
    })
end)

-- 4 fingers: Move window and Fullscreen
pcall(function()
    hl.gesture({
        fingers = 4,
        direction = "swipe",
        action = "move"
    })
end)
pcall(function()
    hl.gesture({
        fingers = 4,
        direction = "pinch",
        action = "fullscreen"
    })
end)

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
    gestures = {
        workspace_swipe = true,
        workspace_swipe_fingers = 3,
    },
    general = { gaps_in = 2 },
    decoration = decorationConfig,
    input = { kb_layout = "de" }
})
