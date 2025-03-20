ENABLE_DEBUG_LOG = true
local variant = Tracker.ActiveVariantUID

Tracker:AddItems("items/settings.jsonc")

ScriptHost:LoadScript("scripts/logic/logic.lua")
ScriptHost:LoadScript("scripts/items.lua")
ScriptHost:LoadScript("scripts/layouts.lua")
ScriptHost:LoadScript("scripts/logic.lua")
ScriptHost:LoadScript("scripts/locations.lua")

Tracker:AddMaps("maps/maps.jsonc")

Tracker:AddLayouts("layouts/settings.jsonc")