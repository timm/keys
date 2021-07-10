#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :

--- Less is more
---
--- - `MY` : options
--- - `EG` : examples of this  code

-- --------------------------------------------
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local dump,pump,new,inc,subsets,csv,
      split,help,cli,EG,L,MY

MY= {  -- options
     data="../data/auto93.csv"
    ,todo= ""
    ,verbose=false
    ,help=[[
Less is more 

--a  ]]}

EG= {} -- examples

--- Convert a table to key, val pairs.
function pump(o) print(dump(o)) end

--- Convert a table to key, val pairs.
function dump(o)
  local sep,s,keys
  keys = {}
  for key,_ in pairs(o) do keys[#keys+1] = key end
  table.sort(keys)
  s,sep= (o._name or "").. "{",""
  for _,k in pairs(keys) do 
    s=s .. sep .. tostring(k).."= "..tostring(o[k])
    sep=", " end
  return s.."}" end

-- Objects can have a name, and can print themselves
function new(self,name, o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.__tostring = function(x)  return dump(x) end
  self._name =name
  return o end

--- Add `n` (defaults to 1) to `d[k]` (self-initializing if needed).
function inc(d,k,n) 
  d[k] = (no or 1) + (d[k] or 0); return d; end

--- Return all subsets of  table `s` (including empty table)
function subsets(s)
  local t = {{}}
  for i = 1, #s do
  for j = 1, #t do t[#t+1] = {s[i],table.unpack(t[j])} end end
  return t end

--- return string `s` divided on `c` (defaults to comma)
function split(s,c)
  local t
  t, c = {}, c or ","
  for y in string.gmatch(s, "([^" ..c.. "]+)") do t[#t+1] = y end
    return t end

--- Iterate over lines, split by commas.
function csv(file)
  local stream = file and io.input(file) or io.input()
  local tmp    = io.read()
  return function()
    if tmp then
      tmp = tmp:gsub("[\t\r ]*","") -- no whitespace
               :gsub("#.*","") -- no cots
      local t = split(tmp)
      tmp = io.read()
      if #t > 0 then
        for j,x in pairs(t) do t[j] = tonumber(x) or x end
      return t end
    else
      io.close(stream) end end end

--- Search command line for flags matching.
function cli(want,got)
  function help(options)
    local f2="  -%-10s  %s" 
    local f1="  +%-10s" 
    print("\n"..options.help.."\n")
    for k,v in pairs(options) do
      if k  ~= "help" then 
        print(v==false and f1:format(k) or f2:format(k,v)) end end end   
  --------------------------
  for k,v in pairs(got) do
    local flag=v:sub(2,#v)
    if   flag == "h" 
    then help(want)
    elseif want[flag]~=nil then 
      if v:sub(1,1) == "+" 
      then want[flag]= true 
      else want[flag]= tonumber(got[k+1]) or got[k+1] end end end 
  return want end

-- --------------------------------------------

-- Run examples 
function EG.all(my)
  for k,v in pairs(EG) do 
    if   k ~="all" and (my.todo==k or my.todo=="")
    then print("\n-- "..k); v(my) end end end 

--- Dump options
function EG.dump(my)  print(dump(my))  end
  
--- Just show contents
function EG.csv(my) 
  for x in csv("../data/auto93.csv") do pump(x) end end

--- Demonstrate  polymorphism
function  EG.poly(my)
  local Dog,Point,p1,p2
  Dog={}
  function Dog:new(o) 
    return new(self,"Dog",{coat='black',age=0}) end
  function Dog:bark()  print(self.age) end
  Point={}
  function Point:new(o) 
    return new(self,"Point",{x=1,y=2}) end
  function Point:bark() print(self.x) end
  p1 = Point:new({x=10})
  p2 = Point:new({x=20, y=Dog:new()})
  print(Point:new():bark())
  print(Dog:new():bark())
  print(p2) end

-- --------------------------------------------
EG.all(cli(MY,arg))
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
