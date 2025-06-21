--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Bevy Mod Scripting interface.
--]]

local bms = require("utils.bms")

local phx = {}

---
--- TODO: Document.
--- TODO: Better input type validation.
---
function phx.spawn_unit(name, pos, player_id)
    -- Spawn a new, empty entity into the world.
    local entity = bms.spawn()

    -- Insert a `Name` component into the entity. This is needed for the server
    -- to lookup additional unit information deserialized from JSON assets.
    bms.insc(entity, "Name", {_1 = name})

    -- Insert a `HexPos` component into the entity. This determines the initial
    -- placement of the unit on the map.
    if type(pos) == "userdata" then
        bms.insc(entity, "HexPos", pos)
    elseif pos.q and pos.r and pos.s then
        bms.insc(entity, "HexPos", {q = pos.q, r = pos.r, s = pos.s})
    elseif pos[1] and pos[2] and pos[3] then
        bms.insc(entity, "Hexpos", {q = pos[1], r = pos[2], s = pos[3]})
    else
        bms.despawn(entity) -- Cleanup.
        error("Invalid `pos` argument")
    end

    -- Insert a `PlayerId` component into the entity. This designates who has
    -- control over the unit and ensures clients render the unit with the
    -- appropriate jersey.
    bms.insc(entity, "PlayerId", {_1 = player_id})
end

return phx

