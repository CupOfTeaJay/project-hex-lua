--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Algorithm for "Wave Function Collapse".
--]]

local bms = require("utils.bms")
local helpers = require("utils.helpers")

local wfc = {}

---
--- Wave Function Collapse Node.
---
wfc.node = {
    new = function(choices)
        local node = {choices = choices, entropy = #choices, neighbors = {}}
        setmetatable(node, wfc.node.metatable)
        return node
    end,
    methods = {
        collapse = function(self)
            return self.choices[math.random(#self.choices)]
        end,
        propagate = function(self)

        end
    }
}
wfc.node.metatable = {
    __index = wfc.node.methods
}

---
--- Creates nodes that mirror the input map template.
---
function wfc._build_nodes(template, sockets)
    local nodes = {}
    local choices = wfc._get_choices(sockets)

    -- First pass: init nodes.
    for row=1,#template do
        nodes[row] = {}
        for col=1,#template[row] do
            local tile = bms.getc(template[row][col], "Tile")
            local mutable = tile.biome ~= "Mountain" and tile.biome ~= "Ocean"
            if tile and mutable then
                nodes[row][col] = wfc.node.new(choices)
            else
                nodes[row][col] = nil
            end
        end
    end

    -- Second pass: insert neighbor references.
    for row=1,#template do
        for col=1,#template[row] do
            for _, neighbor in pairs(wfc._get_neighbors(nodes, row, col)) do
                helpers.insert(
                    nodes[row][col] and nodes[row][col].neighbors, neighbor
                )
            end
        end
    end

    return nodes
end

---
--- Inserts neighbors into a node.
---
function wfc._get_neighbors(nodes, row, col)
    local neighbors = {}
    if (row - 1) % 2 == 0 then
        helpers.insert(neighbors, nodes[row + 1] and nodes[row + 1][col    ])
        helpers.insert(neighbors, nodes[row    ] and nodes[row    ][col - 1])
        helpers.insert(neighbors, nodes[row - 1] and nodes[row - 1][col - 1])
        helpers.insert(neighbors, nodes[row - 1] and nodes[row - 1][col    ])
        helpers.insert(neighbors, nodes[row - 1] and nodes[row - 1][col + 1])
        helpers.insert(neighbors, nodes[row    ] and nodes[row    ][col + 1])
    else
        helpers.insert(neighbors, nodes[row + 1] and nodes[row + 1][col    ])
        helpers.insert(neighbors, nodes[row + 1] and nodes[row + 1][col - 1])
        helpers.insert(neighbors, nodes[row    ] and nodes[row    ][col - 1])
        helpers.insert(neighbors, nodes[row - 1] and nodes[row - 1][col    ])
        helpers.insert(neighbors, nodes[row    ] and nodes[row    ][col + 1])
        helpers.insert(neighbors, nodes[row + 1] and nodes[row + 1][col + 1])
    end
    return neighbors
end

---
--- Determines all tile possibilities from `sockets`.
---
function wfc._get_choices(sockets)
    local choices = {}
    for choice, _ in pairs(sockets) do
        table.insert(choices, choice)
    end
    return choices
end

---
--- Entry-point for Wave Function Collapse.
---
function wfc.collapse(template, sockets)
    local nodes = wfc._build_nodes(template, sockets)
end

return wfc

