local function main(l)
  local t=require "tbl"
  local le=require "learn"
  local o ,oo, any = l.o, l.oo, l.any
  local Tbl = t.Tbl
  
  local function cluster()
    local tbl = Tbl.read("data/auto93.csv")
    tbl:bins()
    local out ={}
    local ts= le.Div2.new(tbl,out) 
    ts:show()
    for _,row in pairs(tbl.rows) do 
      ts:place(tbl,row):add(row.bins) end
    for _,tbl1 in pairs(out) do
       print(tbl1:mid()) end
  end
  cluster()
end

------
package.path='../src/?.lua;'.. package.path 
local l=require "lib"
math.randomseed(1)
main(l)
l.rogues()
