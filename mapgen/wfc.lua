--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Algorithm for "Wave Function Collapse".
--]]

local bms = require("utils.bms")
local map = require("mapgen.map")

local wfc = {}

---
--- TODO:
---
wfc.WaveFunction = {
    new = function(states)
    end,
    methods = {
    },
}
wfc.WaveFunction.metatable = {
    __index = wfc.WaveFunction.methods,
}

function wfc._get_lowest_entropy(nodes)
    local min = nil
    local row = nil
    local col = nil
    local ref = nil
    for _row, _col, _ref in nodes:iter() do
        if not _ref.collapsed and (min == nil or _ref.entropy < min) then
            row = _row
            col = _col
            ref = _ref
            min = _ref.entropy
        end
    end
    return row, col, ref
end

---
--- Entry-point for Wave Function Collapse.
---
function wfc.collapse(template, sockets)
    -- Map template for WFC nodes.
    local nodes = map.template.new(#template[1], #template)

    -- Determine tile possibilities from sockets.
    local choices = {}
    for choice, _ in pairs(sockets) do
        table.insert(choices, choice)
    end

    -- Initialize nodes. We want to update the 'Debug' tiles here. Also
    -- determine possible nucleation sites.
    local nucleation_sites = {}
    for row, col, ref in template:iter() do
        local tile = bms.getc(ref.entity, "Tile")
        if tile.biome == "Debug" then
            nodes[row][col].choices = choices
            nodes[row][col].entropy = #choices
            nodes[row][col].collapsed = false
            table.insert(nucleation_sites, {row = row, col = col})
        else
            nodes[row][col].collapsed = true
        end
    end

    -- Begin the Wave Function Collapse algorithm.
    local site = nucleation_sites[math.random(#nucleation_sites)]
    local node = nodes[site.row][site.col]
    while node do
        -- Collapse.
        local choice = node.choices[math.random(node.entropy)]
        local tile = bms.getc(template[site.row][site.col].entity, "Tile")
        tile.biome = choice
        nodes[site.row][site.col].collapsed = true

        -- Propagate.
        for _, neighbor in pairs(nodes:get_neighbors(site.row, site.col)) do
            if not neighbor.collapsed then
                local new_choices = {}
                for _, possibility in pairs(neighbor.choices) do
                    if sockets[possibility]:contains(choice) then
                        table.insert(new_choices, possibility)
                    end
                end
                neighbor.choices = new_choices
                neighbor.entropy = #neighbor.choices
            end
        end

        -- Get next node.
        site.row, site.col, node = wfc._get_lowest_entropy(nodes)
    end
end

return wfc

