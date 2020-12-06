package.path='../src/?.lua;'.. package.path 
local l=require "lib"
local t=require "tbl"

math.randomseed(1)

local o ,oo, any = l.o, l.oo, l.any
local Tbl = t.Tbl

local function rowsreading()
  local tbl = Tbl.read("../data/auto93.csv")
  assert("Num"==tbl.cols[2].ako,"is Num")
  assert(#tbl.rows==398,"auto rows") end

local function rowsdist()
  local tbl = Tbl.read("../data/weather.csv")
    local r1,r2 = tbl.rows[3], tbl.rows[4]
    o(r1.cells); o(r2.cells)
    print( r1:dist(r2,tbl.xs) ) end

local function rowsdists()
  local tbl = Tbl.read("../data/auto93.csv")
  local all={}
  for i=1,10 do
    local r1,r2 = any(tbl.rows), any(tbl.rows)
    local one ={r1=r1.cells, r2=r2.cells}
    one.d = r1:dist(r2,tbl.xs) 
    all[#all+1] = one
    assert(0== r1:dist(r1,tbl.xs),"sane distance "..i) end
  table.sort(all, function(x,y) return x.d < y.d end)
  for _,one in pairs(tbl.xs) do
     print(one.pos) end
  for _,one in pairs(all) do
     print(""); print(one.d); o(one.r1); o(one.r2) end end

local function binnings()
  local tbl = Tbl.read("../data/auto93.csv")
  tbl:bins() 
  for j=1,30 do l.o(l.any(tbl.rows).bins) end end 

 
rowsreading()
rowsdist()
rowsdists()
binnings()
l.rogues()

