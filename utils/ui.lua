--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Bevy Mod Scripting interface.
--]]

local bms = require("utils.bms")

local ui = {}

---
--- TODO:
---
function ui.border_color(r, g, b, a)
    local srgba = bms.new("Srgba", {red=r, green=g, blue=b, alpha=a})
    local color = bms.new("Color", {variant="Srgba", _1=srgba})
    return bms.new("BorderColor", {_1 = color})
end

---
--- TODO:
---
function ui.ui_rect(left, right, top, bottom)
    return bms.new(
        "UiRect",
        {
            left   = bms.new("Val", {variant="Px", _1 = left}),
            right  = bms.new("Val", {variant="Px", _1 = right}),
            top    = bms.new("Val", {variant="Px", _1 = top}),
            bottom = bms.new("Val", {variant="Px", _1 = bottom}),
        }
    )
end

return ui

