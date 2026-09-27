-- Only personal autostart entries. hl.on is additive: this block runs
-- in addition to hyprland/execs.lua. Do NOT copy original upstream commands
-- here, otherwise services will start twice (e.g. duplicate quickshell instances,
-- multiple clipboard watchers, etc.).
hl.on("hyprland.start", function()
    hl.exec_cmd("[workspace 1] kitty")
    hl.exec_cmd("[workspace 2 silent] zen-browser")
end)
