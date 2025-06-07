--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    TODO: document.
--]]

local bms = require("utils.bms")

local convolution = {}

---
--- TODO: Radius.
---
function convolution.smooth(template, passes)
    for pass=1,passes do
        print("Smoothing map...", pass)
        for row, col, ref in template:iter() do
            local frequencies = {}
            local tile = bms.getc(ref.entity, "Tile")
            frequencies[tile.biome] = 1
            for _, neighbor in pairs(template:get_neighbors(row, col)) do
                tile = bms.getc(neighbor.entity, "Tile")
                if frequencies[tile.biome] then
                    frequencies[tile.biome] = frequencies[tile.biome] + 1
                else
                    frequencies[tile.biome] = 1
                end
            end

            -- Select most frequent.
            local sel = nil
            local max = nil
            for biome, frequency in pairs(frequencies) do
                if max == nil or frequency > max then
                    sel = biome
                    max = frequency
                end
            end
            tile = bms.getc(ref.entity, "Tile")
            tile.biome = sel
        end
    end
end

return convolution

