--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Helper functions.
--]]

local containers = {}

containers.set = {
    new = function(arr)
        local set = {size = 0}
        for _, val in pairs(arr) do
            set[val] = true
            set.size = set.size + 1
        end
        setmetatable(set, containers.set.metatable)
        return set
    end,
    methods = {
        contains = function(self, val)
            if self[val] then return true else return false end
        end,
        insert = function(self, val)
            if not self[val] then
                self[val] = true
                self.size = self.size + 1
            end
        end,
        remove = function(self, val)
            if self[val] then
                self[val] = nil
                self.size = self.size - 1
            end
        end
    }
}
containers.set.metatable = {
    __index = containers.set.methods
}

return containers

