--[[
    Project Hex
    Copyright (c) 2024-2025 Clevermeld™ LLC

    Helper functions.
--]]

local helpers = {}

---
--- Tries to insert a value into a table according to some condition. If there
--- is no condition, then the value will be inserted if itself is non-nil.
---
function helpers.insert(tab, val, con)
    con = con or val
    if con and tab then
        table.insert(tab, val)
    end
end

return helpers

