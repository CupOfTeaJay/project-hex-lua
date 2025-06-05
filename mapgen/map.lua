--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    TODO: Document.
--]]

local map = {}

map.offsets = {
    even_rows = {{1, 0}, {0, -1}, {-1, -1}, {-1, -1}, {-1, 1}, {0, 1}},
    odd_rows = {{1, 0}, {1, -1}, {0, -1}, {-1, 0}, {0, 1}, {1, 1}},
}

map.template = {
    new = function(width, height)
        local template = {}
        for r=1,height do
            template[r] = {}
            for q=1,width do
                template[r][q] = {}
            end
        end
        setmetatable(template, map.template.metatable)
        return template
    end,
    methods = {
        get_hex_pos = function(self, q, r)
            return self:get_row_col(r + 1, q + (r // 2) + 1)
        end,
        get_neighbors = function(self, row, col)
            local neighbors = {}
            local offsets = nil
            if (row - 1) % 2 == 0 then
                offsets = map.offsets.even_rows
            else
                offsets = map.offsets.odd_rows
            end
            for _, offset in pairs(offsets) do
                local ref = self:get_row_col(row + offset[2], col + offset[1])
                if ref then
                    table.insert(neighbors, ref)
                end
            end
            return neighbors
        end,
        get_row_col = function(self, row, col)
            local ref = nil
            if self[row] and self[row][col] then
                ref = self[row][col]
            end
            return ref
        end,
    },
}
map.template.metatable = {
    __index = map.template.methods
}

return map

