-- Nur Abweichungen von hyprland/env.lua -- diese Datei wird ZUSAETZLICH geladen,
-- nicht statt des Originals. Alles was hier nicht steht, kommt weiter aus
-- hyprland/env.lua und bleibt damit automatisch aktuell.
--
-- Hinweis: greift vermutlich nicht, weil hyprland/general.lua input.kb_layout
-- setzt und danach geladen wird. Wirksam ist der Eintrag in general.lua.
hl.env("XKB_DEFAULT_LAYOUT", "de")

-- =============================================================================
-- Keybind-Override für dots-hyprland:
-- Da hl.bind additiv ist und es kein hl.unbind gibt, sind Keybinds nicht additiv.
-- Eine Umbelegung in custom/keybinds.lua würde sonst ZUSÄTZLICH zu hyprland/keybinds.lua
-- feuern (z.B. SUPER+C würde Fenster schließen UND Code-Editor starten).
--
-- Die Lösung: custom/env.lua wird in hyprland.lua VOR hyprland/keybinds.lua geladen.
-- Wenn wir hier package.loaded["hyprland.keybinds"] = true setzen, überspringt
-- require("hyprland.keybinds") das Laden der Upstream-Keybinds komplett!
-- Anschließend lädt hyprland.lua sauber custom/keybinds.lua mit deinen persönlichen Keybinds.
-- Da ~/.config/hypr/custom/ von Upstream-Updates ('./setup install') NIE gelöscht wird,
-- funktionieren deine Keybinds dauerhaft, konfliktfrei und überstehen jedes Update!
-- =============================================================================
if is_file_exists(HOME .. "/.config/hypr/custom/keybinds.lua") then
    package.loaded["hyprland.keybinds"] = true
end
