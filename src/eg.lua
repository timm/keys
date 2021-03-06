#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Unit tests.   
-- Tim Menzies, (c) 2021        

-- -----------------------------
local lib  = require "lib" -- sda asdas  asdasdasa 
local rows = require "rows"
local Sym = require "sym"
local Num = require "num"
local powerset,watch,csv = lib.powerset,lib.watch,lib.csv
local printf,isa,oo,watch= lib.printf,lib.isa,lib.oo,lib.watch
local sd = lib.sd
local add = rows.add
local cli = require "cli"
local Some = require "some"
local Stats = require "stats"
local Rand  = require("rand")

local r=Rand.rand


local eg={}
 
-- ----
-- <a name=some>
-- Test if we can approximate a million numbers with a few samples. 
function eg.lists()
  Rand.srand(1)
  assert(lib.has("bb",{"aa","bb","cc"}))
  assert(not lib.has("kk",{"aa","bb","cc"}))
  assert(10 == lib.any {10,20,30}) 
end

-- ----
-- How well does a new numbers  approximate
-- a normal distribution?
function eg.some1()
  Rand.srand(1)
  local function normalcdf()  -- for -3 <=x <= 3, approximates normal 
     local x=-3+r()*6
     return  1/(1 + math.exp(-0.07056*x^3 - 1.5976*x)) end
  -- load data
  local t={}
  for i=1,10^3 do t[#t+1] = normalcdf() end
  local want=sd(t)
  -- try some approximations
  for max=20,250,25 do
    local s = isa(Some,{max=max})
    for _,x in pairs(t) do s:add(x) end
    printf("%4s  %4.0f", max,  100*(want - s:sd())/want//1) end end

-- Same as some1, but reasoning  over  skewed (non-normal)
-- data.
function eg.some2()
  Rand.srand(1)
  -- load data
  local t={}
  for i=1,10^3 do t[#t+1] = math.random()^0.5 end
  local want=sd(t)
  -- try some approximations
  for max=20,250,25 do
    local s = isa(Some,{max=max})
    for _,x in pairs(t) do s:add(x) end
    printf("%4s  %4.0f", max,  100*(want - s:sd())/want//1) end end

-- ----
-- <a name=cliffs>
-- Check how close we can get before being similar

function eg.cliffs()
  -- load data
  function load(d,n)
    local x,y={},{}
    for i=1,n do 
      x[#x+1] = math.random()
      y[#x]   = d*x[#x] end 
    return x,y end
  -- try some approximations
  for n=32,1000,32 do
    for d=1,1.3,0.025 do
      local x,y = load(d,n)
      if not Stats.cliffsDelta(x,y) then
        printf("for %5s items, things change after delta= %5s", n, d);
        break end end end end

-- ----
function eg.split()
  local str = "a,b,c,d"
  local t   = lib.split(str)
  assert(4 == #t)
  assert("b" == t[2]) end

-- ----
function eg.powerset(   s,t)
  s = {10,20,30,40,50,60,70,80,90,100,110,120,130,140,150}
  t = powerset(s) 
  assert(#t==2^(#s)) end

-- ----
function eg.copy()
  local t1={10,{20}}
  local t2=lib.copy(t1)
  t1[2][1]=30
  assert(t2[2][1] == 20) end

-- ----
function eg.csv()
  local n=0
  for row in lib.csv("../data/auto93.csv") do 
    n=n+1
    if n>1 then assert("number"==type(row[1]),tostring(n)) end end end

-- ----
function eg.num()
  local n = isa(Num)
  for _,v in pairs {600, 470, 170, 430, 300} do add(n,v) end
  assert(n.mu==394)
  assert(147.3 < n.sd and n.sd < 147.4) end

-- ----
function eg.sym()
  local s = isa(Sym)
  for _,v in pairs {"a","b","b","c","c","c","c"} do add(s,v) end
  assert(s.n == 7)
  assert("c"==s.mode)
  assert(1.37 <= s:ent() and s:ent() <=1.38)  end

-- ----
function eg.rows()
  local rows=isa(rows.Rows)
  for row in csv("../data/auto93.csv") do rows:add(row) end
  oo(rows.cols[1]._isa)
  assert(rows.cols[1].n == 398)
  assert(rows.cols[3].n == 397) end

-- function eg.cli(     t)
--   t= cli("./eg.lua", {c = {10, "copyleft"}, 
--                       k = {2,  "low freq"},
--                       optimize = {false, "options"}})
--   oo(t) end
--
-- -----------------------------------
-- And finally...
local txt=arg[1]

if txt then 
  if txt=="?" then for txt,_ in lib.order(eg) do print("./eg.lua "..txt) end end
  if eg[txt]  then print("-- "..txt); eg[arg[1]]()  end
else
  for txt,f in lib.order(eg) do print("-- "..txt); f() end 
end 

lib.rogues()
