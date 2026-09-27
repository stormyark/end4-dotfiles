-- Nur Abweichungen von hyprland/general.lua. hl.config fuehrt verschachtelte
-- Teil-Tabellen zusammen (Beleg: hyprland/colors.lua setzt nur general.col.*,
-- der Rest von general.lua bleibt bestehen), deshalb reichen die Keys, die
-- tatsaechlich abweichen.

-- hl.monitor wird ein zweites Mal aufgerufen; fuer denselben output gewinnt
-- der spaetere Aufruf. https://wiki.hyprland.org/Configuring/Monitors/
-- hl.monitor({
--     output = "",
--     mode = "3440x1440@100",
--     position = "3440x0",
--     scale = 1
-- })

hl.config({
    general = { gaps_in = 2 },
    decoration = {
        active_opacity = 0.975,
        inactive_opacity = 0.97,
        screen_shader = "~/.config/hypr/shaders/vibrance.frag"
    },
    input = { kb_layout = "de" }
})
