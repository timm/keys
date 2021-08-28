package.path = '../src/?.lua;' .. package.path

local _   = require"rand"; local srand,randi = _.srand,_.randi
local pump= require("list").pump
local Some= require"some"; 
local col = require"col"

srand(1)
local a={}
local s=Some:new(64)
for i=1,1000 do a[1+#a] = s:add(randi(1,100),s) end 
pump(s:all())

