-- Nur Abweichungen von hyprland/general.lua. hl.config fuehrt verschachtelte
-- Teil-Tabellen zusammen (Beleg: hyprland/colors.lua setzt nur general.col.*,
-- der Rest von general.lua bleibt bestehen), deshalb reichen die Keys, die
-- tatsaechlich abweichen.

-- hl.monitor wird ein zweites Mal aufgerufen; fuer denselben output gewinnt
-- der spaetere Aufruf. https://wiki.hyprland.org/Configuring/Monitors/
hl.monitor({
    output = "",
    mode = "3440x1440@100",
    position = "3440x0",
    scale = 1
})

local homeDir = HOME or os.getenv("HOME") or ""
local shaderPath = homeDir .. "/.config/hypr/shaders/vibrance.frag"

local decorationConfig = {
    active_opacity = 0.975,
    inactive_opacity = 0.97,
}

-- Hyprlands Shader-Parser akzeptiert keine Tilde '~', sondern benoetigt den absoluten Pfad.
-- Wir pruefen, ob die Shader-Datei existiert, bevor wir sie uebergeben.
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
