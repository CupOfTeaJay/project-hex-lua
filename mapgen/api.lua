--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Project Hex's "noise" API. This is used during the map-generation process
    to assign elevations, terrains, etcetera, to tiles.
--]]

local api = {}

local common = require("mapgen.common")
local perlin = require("mapgen.perlin")
local worley = require("mapgen.worley")

local func_map = {}
func_map["perlin"] = perlin.perlin_3d
func_map["worley"] = worley.worley_3d

---
--- Generates a two-dimensional noise map by sampling a multitude of three-
--- dimensional noise functions.
---
--- @param map_width integer Width of the noise map to generate.
--- @param map_height integer Height of the noise map to generate.
--- @param noise_request table Noise functions used to generate noise.
---
function api.generate_noise(map_width, map_height, noise_request)
    -- Initialize sample and gradient tables for layering purposes.
    local samples = {}
    local grads   = {}
    for r=1,map_height do
        samples[r] = {}
        grads[r]   = {}
        for q=1,map_width do
            samples[r][q] = 0.0
            grads[r][q]   = 0.0
        end
    end

    -- Service the `noise_request`. Our `samples` should be a superposition of
    -- all noise functions specified in the `noise_request`.
    for i=1,#noise_request do
        -- Unwrap arguments.
        local noise_func  = noise_request[i][1]
        local octaves     = noise_request[i][2]
        local scale       = noise_request[i][3]
        local persistence = noise_request[i][4]
        local lacunarity  = noise_request[i][5]

        -- Vars to update per cylindrical cross-section.
        local theta = 0.0
        local z     = 0.0

        -- Sample a 3D noise field.
        for r=1,map_height do
            for q=1,map_width do
                -- Vars to update per-octave.
                local amplitude = 1.0
                local frequency = 1.0
                local sample    = 0.0

                -- Sample a point from the noise-field along with the gradient
                -- vector at that point.
                local tmp  = nil
                local grad = nil
                for _=1,octaves do
                    tmp, grad = func_map[noise_func](
                        math.cos(theta)/(scale*frequency),
                        math.sin(theta)/(scale*frequency),
                        z/(scale*frequency)
                    )
                    tmp       = tmp*amplitude
                    sample    = sample + tmp
                    amplitude = amplitude*persistence
                    frequency = frequency*lacunarity

                    -- "Gradient Trick":
                    -- https://www.youtube.com/watch?v=gsJHzBTPG0Y&t=590s
                    grads[r][q] = grads[r][q] + grad:magnitude()
                    sample      = 1/(1 + 0.10*grads[r][q])
                end

                -- Save the current sample.
                samples[r][q] = samples[r][q] + sample

                -- Advance along the current ring, if we need to.
                theta = theta + (2.0*math.pi)/(map_width)
            end

            -- We've finished sampling all points along some ring. Advance to
            -- the next ring.
            z = z + (map_height)/(map_width*2*math.pi)
            theta = 0.0
        end
    end

    -- Normalize samples and forward to caller.
    common.normalize(samples)
    return samples
end

return api
