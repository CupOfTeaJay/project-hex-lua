--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    server/lua/ph-noise/worley.lua

    Implementation of the Worley noise algorithm.

    TODO: Generalize distance calculation for nth closest feature, along with
          their gradient calculations.
--]]

---
--- common: Common logic for ph-noise.
--- ptable: Permutation table used for psuedo-random "feature" point
---         calculations.
--- worley: The worley noise module.
---
local common = require("ph-noise.common")
local ptable = common.gen_ptable()
local worley = {}

--
-- Generates a pseudo-random "feature" point given the coordinates of a
-- unit-cell resident in the Worley noise field. A global permutation table in
-- conjunction with arbitrarily selected primes (2, 3, 5, 7, 11, 13) is used
-- as the source of entropy.
--
-- @param cell table Vector that is representative of a cell's "root" vertex.
-- @return table Vector that is representative of the generated feature.
--
local function generate_feature(cell)
    return cell + common.vec3.new(
        ptable[ptable[ptable[cell.x & 255      ] + (cell.y & 255)       ] + (cell.z & 255)       ] / 255.0,
        ptable[ptable[ptable[(cell.x + 2) & 255] + ((cell.y + 3) & 255) ] + ((cell.z + 5) & 255) ] / 255.0,
        ptable[ptable[ptable[(cell.x + 7) & 255] + ((cell.y + 11) & 255)] + ((cell.z + 13) & 255)] / 255.0
    )
end

--
-- Calculates the Minkowski distance between two cartesian vectors according to
-- the Minkowski Parameter, "p".
--
-- Metrics:
--     - Manhattan  (p=1).
--     - Euclidean  (p=2).
--     - Chebyeshev (p=infinity).
--
-- @param a table First input vector.
-- @param b table Second input vector.
-- @param p integer The Minkowski Parameter.
--
local function minkowski_distance(a, b, p)
    return (math.abs(a.x - b.x)^p + math.abs(a.y - b.y)^p + math.abs(a.z - b.z)^p)^(1/p)
end

---
--- Generate 3D Worley noise (cellular noise) at the given point.
--- Returns the distance to the closest feature point, normalized to [0,1],
--- along with its associated gradient vector.
---
--- @param x number Cartesian "x" coordinate.
--- @param y number Cartesian "y" coordinate.
--- @param z number Cartesian "z" coordinate.
--- @param minkowski_parameter number Minkowski distance metric parameter.
---
function worley.worley_3d(x, y, z, minkowski_parameter)
    -- Default to the Euclidean metric if necessary.
    minkowski_parameter = minkowski_parameter or 2
    if minkowski_parameter < 1 then
        minkowski_parameter = 2
    end

    -- Values to return.
    local noise_sample = nil
    local gradient     = nil

    -- Vectorize the input coordinates and determine the "root" cell they fall
    -- into.
    local input_vec = common.vec3.new(x, y, z)
    local root_cell = common.vec3.new(math.floor(x), math.floor(y), math.floor(z))

    -- We can think of a 3x3x3 cube centered at our root_cell. The next step is
    -- to iterate through all of the component unit cubes/cells (27 in total)
    -- to perform a few operations.
    for x_offset = -1, 1 do
        for y_offset = -1, 1 do
            for z_offset = -1, 1 do
                -- Determine the current cell to evaluate.
                local curr_cell = root_cell + common.vec3.new(x_offset, y_offset, z_offset)

                -- Generate the feature point for this cell. This is the key to
                -- Worley noise. Each grid cell contains exactly one randomly
                -- positioned feature point.
                local feature = generate_feature(curr_cell)

                -- Calculate the distance from our input position to the feature point.
                local distance = minkowski_distance(input_vec, feature, minkowski_parameter)

                -- If we've encountered a feature closer to the one previous
                -- then save the distance to it as our noise sample and 
                -- calculate its corresponding gradient.
                if noise_sample == nil or distance < noise_sample then
                    noise_sample = distance
                    gradient     = feature - input_vec
                end
            end
        end
    end

    -- Forward the calculated noise sample and gradient to caller. Note that
    -- the noise_sample is clamped to a maximum of 1.0 and inverted such that
    -- features indicate "peaks" in one's heightmap.
    -- TODO: We may not need to clamp here?
    return 1.0 - math.min(1.0, noise_sample), gradient
end

return worley
