local function main(l)
  local t=require "tbl"
  local le=require "learn"
  local o ,oo, any = l.o, l.oo, l.any
  local Tbl = t.Tbl
  
  local function cluster()
    local tbl = Tbl.read("data/auto93.csv")
    le.Div2.new(tbl) end
  
  cluster()
end

------
package.path='../src/?.lua;'.. package.path 
local l=require "lib"
math.randomseed(1)
main(l)
l.rogues()
