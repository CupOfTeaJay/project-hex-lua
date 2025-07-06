--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Bevy Mod Scripting interface.
--]]

local bms = require("utils.bms")

local input = {}

---
--- TODO:
---
function input.add_player()
    bms.getr("InputBuffer"):queue(
        bms.new("Input", {variant="AddPlayer"})
    )
end

return input

