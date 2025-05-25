--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    lua/mapgen/perlin.lua

    TODO: Document.

    NOTE: TODO: credit.
        - https://gist.github.com/kymckay/25758d37f8e3872e1636d90ad41fe2ed
        - https://adrianb.io/2014/08/09/perlinnoise.html
        - https://iquilezles.org/articles/gradientnoise/
--]]

---
--- TODO: Document.
---
local common = require("mapgen.common")
local ptable = common.gen_ptable()
local perlin = {}

--
-- Gradient function finds dot product between pseudorandom gradient vector
-- and the vector from input coordinate to a unit cube vertex.
--
local dot_products = {
    [0x0]=function(x,y,_) return  x + y end,
    [0x1]=function(x,y,_) return -x + y end,
    [0x2]=function(x,y,_) return  x - y end,
    [0x3]=function(x,y,_) return -x - y end,
    [0x4]=function(x,_,z) return  x + z end,
    [0x5]=function(x,_,z) return -x + z end,
    [0x6]=function(x,_,z) return  x - z end,
    [0x7]=function(x,_,z) return -x - z end,
    [0x8]=function(_,y,z) return  y + z end,
    [0x9]=function(_,y,z) return -y + z end,
    [0xA]=function(_,y,z) return  y - z end,
    [0xB]=function(_,y,z) return -y - z end,
}

--
-- Psuedorandom gradient vectors. Each entry represents a vector pointing from
-- the origin of a unit cube to the center of one of its edges.
--
local gradient_vectors = {
    [0x0]=common.vec3.new( 1,  1,  0),
    [0x1]=common.vec3.new(-1,  1,  0),
    [0x2]=common.vec3.new( 1, -1,  0),
    [0x3]=common.vec3.new(-1, -1,  0),
    [0x4]=common.vec3.new( 1,  0,  1),
    [0x5]=common.vec3.new(-1,  0,  1),
    [0x6]=common.vec3.new( 1,  0, -1),
    [0x7]=common.vec3.new(-1,  0, -1),
    [0x8]=common.vec3.new( 0,  1,  1),
    [0x9]=common.vec3.new( 0, -1,  1),
    [0xA]=common.vec3.new( 0,  1, -1),
    [0xB]=common.vec3.new( 0, -1, -1),
}

--
-- Analytical derivative of the `fade` function.
--
local function dfade(t)
    return 30*t^4 - 60*t^3 + 30*t^2
end

--
-- TODO: Document.
--
local function dot(hash, x, y, z)
    return dot_products[hash & 0xB](x,y,z)
end

--
-- TODO: Document.
--
local function fade(t)
    return 6*t^5 - 15*t^4 + 10*t^3
end

--
-- TODO: Document.
--
local function grad(hash)
    return gradient_vectors[hash & 0xB]
end

---
--- TODO: Document.
---
local function translate_domain(sample)
    return (sample + 1)*0.5
end

---
--- TODO: Document.
---
function perlin.perlin_3d(x, y, z)
    -- Calculate the 'root' vertex of the unit-cube the input cartesian
    -- coordinates fall into. We can traverse to the other vertices of our
    -- unit cube by incrementing components of this root vertex by 1.
    local v0_x = math.floor(x) & 255
    local v0_y = math.floor(y) & 255
    local v0_z = math.floor(z) & 255

    -- Determine where the input cartesian coordinates lie within our unit
    -- cube (just preserve the fractional parts of x, y, and z).
    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)

     -- Fade "factors". These will be used to smoothly interpolate the gaps
     -- between points in the noise-field.
    local q  = fade(x)
    local r  = fade(y)
    local s  = fade(z)
    local du = common.vec3.new(dfade(x), dfade(y), dfade(z))

    -- Determine hash values for all 8 vertices of the unit cube.
    local h000 = ptable[ptable[ptable[v0_x    ] + v0_y      ] + v0_z      ]
    local h001 = ptable[ptable[ptable[v0_x    ] + v0_y      ] + (v0_z + 1)]
    local h010 = ptable[ptable[ptable[v0_x    ] + (v0_y + 1)] + v0_z      ]
    local h011 = ptable[ptable[ptable[v0_x    ] + (v0_y + 1)] + (v0_z + 1)]
    local h100 = ptable[ptable[ptable[v0_x + 1] + v0_y      ] + v0_z      ]
    local h101 = ptable[ptable[ptable[v0_x + 1] + v0_y      ] + (v0_z + 1)]
    local h110 = ptable[ptable[ptable[v0_x + 1] + (v0_y + 1)] + v0_z      ]
    local h111 = ptable[ptable[ptable[v0_x + 1] + (v0_y + 1)] + (v0_z + 1)]

    -- Determine the psuedorandom gradient vectors for all 8 vertices of the 
    -- unit cube. 
    local g000 = grad(h000)
    local g001 = grad(h001)
    local g010 = grad(h010)
    local g011 = grad(h011)
    local g100 = grad(h100)
    local g101 = grad(h101)
    local g110 = grad(h110)
    local g111 = grad(h111)

    -- Calculate the projection of our gradient vectors onto vertex
    -- displacement from the origin.
    local p000 = dot(h000, x,     y,     z    )
    local p001 = dot(h001, x,     y,     z - 1)
    local p010 = dot(h010, x,     y - 1, z    )
    local p011 = dot(h011, x,     y - 1, z - 1)
    local p100 = dot(h100, x - 1, y,     z    )
    local p101 = dot(h101, x - 1, y,     z - 1)
    local p110 = dot(h110, x - 1, y - 1, z    )
    local p111 = dot(h111, x - 1, y - 1, z - 1)

    -- // Interpolation.
    -- float v = va + 
    --          u.x*(vb-va) + 
    --          u.y*(vc-va) + 
    --          u.z*(ve-va) + 
    --          u.x*u.y*(va-vb-vc+vd) + 
    --          u.y*u.z*(va-vc-ve+vg) + 
    --          u.z*u.x*(va-vb-ve+vf) + 
    --          u.x*u.y*u.z*(-va+vb+vc-vd+ve-vf-vg+vh);
    local sample = p000 +
                   q*(p100 - p000) +
                   r*(p010 - p000) +
                   s*(p001 - p000) +
                   q*r*(p000 - p100 - p010 + p110) +
                   r*s*(p000 - p010 - p001 + p011) +
                   s*q*(p000 - p100 - p001 + p101) +
                   q*r*s*(-p000 + p100 + p010 - p110 + p001 - p101 - p011 + p111)

    -- // Gradient.
    -- vec3 d = ga +
    --          u.x*(gb-ga) +
    --          u.y*(gc-ga) +
    --          u.z*(ge-ga) +
    --          u.x*u.y*(ga-gb-gc+gd) +
    --          u.y*u.z*(ga-gc-ge+gg) +
    --          u.z*u.x*(ga-gb-ge+gf) +
    --          u.x*u.y*u.z*(-ga+gb+gc-gd+ge-gf-gg+gh) +
    --
    --          du * (vec3(vb-va,vc-va,ve-va) +
    --                u.yzx*vec3(va-vb-vc+vd,va-vc-ve+vg,va-vb-ve+vf) +
    --                u.zxy*vec3(va-vb-ve+vf,va-vb-vc+vd,va-vc-ve+vg) +
    --                u.yzx*u.zxy*(-va+vb+vc-vd+ve-vf-vg+vh) ));
    local dsample = g000 +
                    (g100 - g000):scale(q) +
                    (g010 - g000):scale(r) +
                    (g001 - g000):scale(s) +
                    (g000 - g100 - g010 + g110):scale(q*r) +
                    (g000 - g010 - g001 + g011):scale(r*s) +
                    (g000 - g100 - g001 + g101):scale(s*q) +
                    (g000:scale(-1) + g100 + g010 - g110 + g001 - g101 - g011 + g111):scale(q*r*s) +
                    du*(
                        common.vec3.new(p100 - p000, p010 - p000, p001 - p000) +
                        common.vec3.new(r, s, q)*common.vec3.new(p000 - p100 - p010 + p110, p000 - p010 - p001 + p011, p000 - p100 - p001 + p101) +
                        common.vec3.new(s, q, r)*common.vec3.new(p000 - p100 - p001 + p101, p000 - p100 - p010 + p110, p000 - p010 - p001 + p011) +
                        common.vec3.new(r, s, q)*common.vec3.new(s, q, r):scale(-p000 + p100 + p010 - p110 + p001 - p101 - p011 + p111)
                    )

    -- Forward Perlin noise sample & gradient for the input Cartesian
    -- coordinates.
    return translate_domain(sample), dsample
end

return perlin

