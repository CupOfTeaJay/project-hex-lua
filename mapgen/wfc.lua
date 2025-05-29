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
        propagate = function(self, choice, sockets)
            -- Build a new list of compatible choices.
            local new_choices = {}
            for _, possibility in ipairs(self.choices) do
                local purge = true
                for _, compatible in pairs(sockets[possibility]) do
                    if choice == compatible then
                        purge = false
                        break
                    end
                end
                if not purge then
                    table.insert(new_choices, possibility)
                end
            end
            self.choices = new_choices
            self.entropy = #new_choices
        end,
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
            if tile and wfc._is_collapsible(tile) then
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
--- Gets indices of the least entropic node.
---
function wfc._get_least_entropic(nodes)
    local min = nil
    local row = nil
    local col = nil
    for _row=1,#nodes do
        for _col=1,#nodes[_row] do
            local node = nodes[_row][_col]
            if node and (min == nil or node.entropy < min) then
                min = node.entropy
                row = _row
                col = _col
            end
        end
    end
    return row, col
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
--- Determines if a tile has a collapsible biome.
---
function wfc._is_collapsible(tile)
    return (
        tile.biome ~= "Mountain" and
        tile.biome ~= "Ocean" and
        tile.biome ~= "Coastal"
    )
end

---
--- Entry-point for Wave Function Collapse.
--- TODO: Nucleate?
---
function wfc.collapse(template, sockets)
    local nodes = wfc._build_nodes(template, sockets)
    local row, col = wfc._get_least_entropic(nodes)
    while row and col do
        -- Collapse node.
        local choice = nodes[row][col]:collapse()

        -- Update Tile biome.
        local tile = bms.getc(
            template[row][col],
            "Tile"
        )
        tile.biome = choice

        -- Propagate collapse to neighbors.
        for _, neighbor in pairs(nodes[row][col].neighbors) do
            neighbor:propagate(choice, sockets)
        end

        -- Remove this node and Get next node.
        nodes[row][col] = nil
        row, col = wfc._get_least_entropic(nodes)
    end
end

return wfc

