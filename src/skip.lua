#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Columns for things we just ignore.     
-- (c) Tim Menzies, 2021   

local Skip= {at=0, txt="", n=0}

function Skip:add(x) return true end
function Skip:mid()  return "?" end

return Skip
