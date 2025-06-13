--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Algorithm for "Wave Function Collapse".
--]]

local bms = require("utils.bms")
local dict = require("utils.containers").dict

local wfc = {}

---
--- TODO:
---
wfc.WaveFunction = {
    new = function(states)
        local wave_function = {dict.new({})}
        for state, prob in pairs(states) do
            wave_function[1]:insert(state, prob)
        end
        setmetatable(wave_function, wfc.WaveFunction.metatable)
        return wave_function
    end,
    methods = {
        collapse = function(self)
            local rand = math.random()
            local cursor = 0
            local choice = nil
            for key, val in pairs(self[1]:iter()) do
                cursor = cursor + val
                if cursor > rand then
                    choice = key
                    break
                end
            end
            self[1]:clear()
            return choice
        end,
        get_entropy = function(self)
            return self[1].size
        end,
        is_collapsed = function(self)
            return self[1].size == 0
        end,
        propagate = function(self, choice, sockets)
            local popped = 0.0
            for state, prob in pairs(self[1]:iter()) do
                if sockets[choice] and not sockets[choice]:contains(state) then
                    self[1]:remove(state)
                    popped = popped + prob
                end
            end
            for state, prob in pairs(self[1]:iter()) do
                self[1]:insert(state, prob + popped/self[1].size)
            end
        end,
    },
}
wfc.WaveFunction.metatable = {
    __index = wfc.WaveFunction.methods,
}

function wfc._get_lowest_entropy(template)
    local min = nil
    local _row = nil
    local _col = nil
    local _ref = nil
    for row, col, ref in template:iter() do
        if not ref.wave_function:is_collapsed() then
            local entropy = ref.wave_function:get_entropy()
            if min == nil or entropy < min then
                min = entropy
                _row = row
                _col = col
                _ref = ref
            end
        end
    end
    return _row, _col, _ref
end

---
--- Entry-point for Wave Function Collapse.
---
function wfc.collapse(template, sockets)
    local row, col, ref = wfc._get_lowest_entropy(template)
    local prev = nil
    while ref do
        local choice = ref.wave_function:collapse()
        if not choice then choice = prev end
        prev = choice
        bms.insc(
            ref.entity,
            "Tile",
            bms.new(
                "Tile",
                {
                    biome = choice,
                    terrains = {},
                    features = {}
                }
            )
        )
        for _, neighbor in pairs(template:get_neighbors(row, col)) do
            neighbor.wave_function:propagate(choice, sockets)
        end
        row, col, ref = wfc._get_lowest_entropy(template)
    end
end

return wfc

