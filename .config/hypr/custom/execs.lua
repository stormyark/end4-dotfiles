-- Nur die eigenen Autostart-Zeilen. hl.on ist additiv: dieser Block laeuft
-- zusaetzlich zu dem aus hyprland/execs.lua. Deshalb NICHT das Original
-- mitkopieren -- sonst startet alles doppelt (zwei Quickshell-Instanzen,
-- vier wl-paste-Watcher).
hl.on("hyprland.start", function()
    hl.exec_cmd("[workspace 1] kitty")
    hl.exec_cmd("[workspace 2 silent] zen-browser")
end)
