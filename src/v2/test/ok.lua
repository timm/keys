package.path = '../src/?.lua;' .. package.path

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local the  = require"cli"
local str  = require"strings"
local rand = require"rand"
local list = require"list"

local fails=0
for _,f in pairs(arg) do
   if f ~= "ok.lua" and f ~= "lua" then
     rand.srand(the.seed)
     local status,err=  pcall(function () dofile(f) end) 
     if status then
       str.color("green","✔ %s",f)
     else
      fails=fails+1
      str.color("red","✘ %s",tostring(err)) end end end 

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
os.exit(fails)
