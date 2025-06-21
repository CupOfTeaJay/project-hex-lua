--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Bevy Mod Scripting interface.
--]]

--- @diagnostic disable:undefined-global

local bms = {}

---
--- Despawns the provided entity from the world.
---
function bms.despawn(entity)
    world.despawn(entity)
end

---
--- Gets a component from an entity.
---
function bms.getc(entity, name)
    return world.get_component(entity, world.get_type_by_name(name))
end

---
--- Gets a resource from the world.
---
function bms.getr(name)
    return world.get_resource(world.get_type_by_name(name))
end

---
--- Inserts a component into an entity.
---
function bms.insc(entity, name, component)
    return world.insert_component(
        entity,
        world.get_type_by_name(name),
        component
    )
end

---
--- Constructs a new instance of a registered type.
---
function bms.new(name, data)
    return construct(world.get_type_by_name(name), data)
end

---
--- Queries the world for the given components.
---
function bms.query(names)
    local query = world.query()
    for _, name in pairs(names) do
        query = query:component(world.get_type_by_name(name))
    end
    return query:build()
end

---
--- Spawns a new entity in the world and returns a reference to it.
---
function bms.spawn()
    return world.spawn()
end

return bms

