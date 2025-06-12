--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Helper functions.
--]]

local containers = {}

containers.dict = {
    new = function(t)
        local dict = {size = 0}
        for key, val in pairs(t) do
            dict[key] = val
            dict.size = dict.size + 1
        end
        setmetatable(dict, containers.dict.metatable)
        return dict
    end,
    methods = {
        clear = function(self)
            for key, _ in pairs(self) do
                if key ~= "size" then
                    self[key] = nil
                    self.size = self.size - 1
                end
            end
        end,
        contains = function(self, key)
            if self[key] then return true else return false end
        end,
        insert = function(self, key, val)
            if not self[key] then
                self[key] = val
                self.size = self.size + 1
            else
                self[key] = val
            end
        end,
        iter = function(self)
            local items = {}
            for key, val in pairs(self) do
                if key ~= "size" then
                    items[key] = val
                end
            end
            return items
        end,
        remove = function(self, key)
            if self[key] then
                self[key] = nil
                self.size = self.size - 1
            end
        end
    },
}
containers.dict.metatable = {
    __index = containers.dict.methods
}

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

