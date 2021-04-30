#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Unit tests.   
-- Tim Menzies, (c) 2021        

-- -----------------------------
local lib  = require "lib"
local rows = require "rows"
local powerset,watch,csv = lib.powerset,lib.watch,lib.csv
local isa,oo             = lib.isa,lib.oo
local add = rows.add

math.randomseed(1)
local eg={}

function eg.lists()
  assert(lib.has("bb",{"aa","bb","cc"}))
  assert(not lib.has("kk",{"aa","bb","cc"}))
  assert(30 == lib.any {10,20,30}) end

function eg.split()
  local str = "a,b,c,d"
  local t   = lib.split(str)
  assert(4 == #t)
  assert("b" == t[2]) end

function eg.copy()
  local t1={10,{20}}
  local t2=lib.copy(t1)
  t1[2][1]=30
  assert(t2[2][1] == 20) end

function eg.csv()
  local n=0
  for row in lib.csv("../data/auto93.csv") do 
    n=n+1
    if n>1 then assert("number"==type(row[1]),tostring(n)) end end end

function eg.powerset(   s,t)
  s = {10,20,30,40,50,60,70,80,90,100,110,120,130,140,150}
  t = powerset(s) 
  assert(#t==2^(#s)) end

function eg.rows()
  local rows=isa(rows.Rows)
  for row in csv("../data/auto93.csv") do rows:add(row) end
  assert(rows.cols[1].n == 398)
  assert(rows.cols[3].n == 397) end

function eg.num()
  local n = isa(rows.Num)
  for _,v in pairs {600, 470, 170, 430, 300} do add(n,v) end
  assert(n.mu==394)
  assert(147.3 < n.sd and n.sd < 147.4) end


-- -----------------------------------
-- And finally...

for txt,f in lib.order(eg) do print("-- "..txt); f(); end
lib.rogues()
