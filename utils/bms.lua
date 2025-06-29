--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Bevy Mod Scripting interface.
--]]

--- @diagnostic disable:undefined-global

local bms = {}

---
--- Inserts children into an entity
---
function bms.pushc(entity, children)
    world.push_children(entity, children)
end

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
    -- TODO: Remove if we can construct `Name` in lua.
    if name == "Name" then
        return Name.new(data.name)
    elseif name == "Node" then
        return Node.new()
    else
        return construct(world.get_type_by_name(name), data)
    end
end

---
--- Queries the world for the given components.
---
function bms.query(names, withs, withouts)
    withs = withs or {}
    withouts = withouts or {}
    local query = world.query()
    for _, name in pairs(names) do
        query = query:component(world.get_type_by_name(name))
    end
    for _, with in pairs(withs) do
        query = query:with(world.get_type_by_name(with))
    end
    for _, without in pairs(withouts) do
        query = query:without(world.get_type_by_name(without))
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

