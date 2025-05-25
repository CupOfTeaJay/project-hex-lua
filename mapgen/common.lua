--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    TODO: document.
--]]

local common = {}

---
--- TODO: Document.
---
function common.gen_ptable()
    -- Init vars.
    local ptable = {
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
        16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
        32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
        48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
        64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
        80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
        96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
        112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
        128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
        144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
        160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
        176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
        192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
        208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
        224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
        240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255,
    }
    local understand_me = {}

    -- Fisher-Yates shuffle
    -- TODO: Credit.
    for i = 1, #ptable - 1 do
        local r = math.random(i, #ptable)
        ptable[i], ptable[r] = ptable[r], ptable[i]
    end

    -- TODO: Understand
    -- p is used to hash unit cube coordinates to [0, 255]
    for i=0,255 do
        -- Convert to 0 based index table
        understand_me[i] = ptable[i+1]
        -- Repeat the array to avoid buffer overflow in hash function
        understand_me[i+256] = ptable[i+1]
    end

    -- Forward permutation table to caller.
    return understand_me
end

--
-- TODO: Document.
--
function common.normalize(samples)
    -- Vars.
    local maximum = samples[1][1]
    local minimum = samples[1][1]

    -- First iteration: find matrix global minimum and maximum.
    for i = 1, #samples do
        for j = 1, #samples[i] do
            if samples[i][j] > maximum then
                maximum = samples[i][j]
            end
            if samples[i][j] < minimum then
                minimum = samples[i][j]
            end
        end
    end

    -- Second iteration: normalize all matrix values.
    for i = 1, #samples do
        for j = 1, #samples[i] do
            samples[i][j] = (samples[i][j] - minimum)/(maximum - minimum)
        end
    end
end

--
-- TODO: Document.
-- TODO: Replace local/setmetatable with :new() for each metamethod.
--
common.vec3 = {
    new = function(x, y, z)
        local vec3 = {x=x, y=y, z=z}
        setmetatable(vec3, common.vec3.metatable)
        return vec3
    end,
    methods = {
        add = function(a, b)
            local result = {x = a.x + b.x, y = a.y + b.y, z = a.z + b.z}
            setmetatable(result, common.vec3.metatable)
            return result
        end,
        band = function(self, mask)
            local result = {x = self.x & mask, y = self.y & mask, z = self.z & mask}
            setmetatable(result, common.vec3.metatable)
            return result
        end,
        eq = function(a, b)
            return a.x == b.x and a.y == b.y and a.z == b.z
        end,
        magnitude = function(self)
            return math.sqrt(self.x^2 + self.y^2 + self.z^2)
        end,
        multiply = function(a, b)
            local result = {x = a.x*b.x, y = a.y*b.y, z = a.z*b.z}
            setmetatable(result, common.vec3.metatable)
            return result
        end,
        scale = function(self, scalar)
            local result = {x = self.x*scalar, y = self.y*scalar, z = self.z*scalar}
            setmetatable(result, common.vec3.metatable)
            return result
        end,
        subtract = function(a, b)
            local result = {x = a.x - b.x, y = a.y - b.y, z = a.z - b.z}
            setmetatable(result, common.vec3.metatable)
            return result
        end,
    },
}
common.vec3.metatable = {
    __add   = common.vec3.methods.add,
    __band  = common.vec3.methods.band,
    __eq    = common.vec3.methods.eq,
    __index = common.vec3.methods,
    __mul   = common.vec3.methods.multiply,
    __sub   = common.vec3.methods.subtract,
}

return common

