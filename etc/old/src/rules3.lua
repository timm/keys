#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

--- Contrast set learning
-- @author Tim Menzies
-- @copyright 2021
-- @license unlicense.org

--- @usage
local usage = [[
Rules3 v3.0 : Contrast set learning
(c) 2021 Tim Menzies timm@ieee.org, unlicense.org

The difference between things (in the same domain) is 
often shorter to describe than the things themselves.

USAGE: ./rules.lua [OPTIONS]

OPTIONS:

    -h          print help
    -data FILE  read data from FILE
    +verbose    enable verbose mode
]] 

local MY={data   = "../data/auto93.csv"
         ,todo   = ""
         ,verbose= false}

----------------------------------------------------
--- Table functions.
-- Useful utilities for opening foobar format files.
-- @section Table
local Tab={}

--- Convert a table to key, val pairs, then print it.
function Tab.pump(o) print(Tab.dump(o)) end

--- Convert a table to key, val pairs.
function Tab.dump(o)
  local sep, s, keys = "", (o._name or "") .."{", {}
  for key,_ in pairs(o) do keys[#keys+1] = key end
  table.sort(keys)
  for _,k in pairs(keys) do 
    s=s .. sep .. tostring(k).."= "..tostring(o[k])
    sep=", " end
  return s.."}" end

--- Add `n` (defaults to 1) to `d[k]` (self-initializing if needed).
function Tab.inc(d,k,n) 
  d[k] = (no or 1) + (d[k] or 0); return d; end

--- Return all subsets of  table `s` (including empty table)
function Tab.subsets(s)
  local t = {{}}
  for i = 1, #s do
  for j = 1, #t do t[#t+1] = {s[i],table.unpack(t[j])} end end
  return t end

----------------------------------------------------
--- File functions.
-- Useful utilities for opening foobar format files.
-- @section File
local File={}

--- Iterate over lines, split by commas.
function File.csv(file)
  local  function split(s,c)
    local t
    t, c = {}, c or ","
    for y in string.gmatch(s, "([^" ..c.. "]+)") do t[#t+1] = y end
      return t end
  local stream = file and io.input(file) or io.input()
  local tmp    = io.read()
  ----------------------
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

----------------------------------------------------
--- Object functions.
-- Useful utilities for opening foobar format files.
-- @section Object
local Obj={}

--- Objects can have a name, and can print themselves
function Obj.new(self,name, o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.__tostring = function(x)  return Tab.dump(x) end
  self._name =name
  return o end

----------------------------------------------------
--- System functions.
-- Useful utilities for opening foobar format files.
-- @section System
local Sys={}

--- Search command line for flags matching keys in `want`.
function Sys.cli(want,got)
  for k,v in pairs(got) do
    local flag=v:sub(2,#v)
    if     flag == "h" 
    then   print(usage); os.exit()
    elseif want[flag] ~=  nil then 
      if v:sub(1,1) == "+" 
      then want[flag] = true 
      else want[flag] = tonumber(got[k+1]) or got[k+1] end end end 
  return want end

----------------------------------------------------
--- Num functions.
-- Useful utilities for opening foobar format files.
-- @type Num
local Num={}

--- Numbers have standard deviation.
function Num:new(at,txt) 
    return Obj.new(self,"NUM",{at=at or 0, txt=txt or "",
                           n=0, w=1, sd=0}) end

----------------------------------------------------
--- Eg functions.
-- Useful utilities for opening foobar format files.
-- @section Eg
local Eg={}

--- Run examples 
function Eg.all(my)
  for k,v in pairs(Eg) do 
    if   k ~="all" and (my.todo==k or my.todo=="")
    then print("\n-- "..k); v(my) end end end 

--- Dump options
function Eg.dump(my)  print(Tab.dump(my))  end
  
--- Just show contents
function Eg.csv(my) 
  for x in File.csv("../data/auto93.csv") do Tab.pump(x) end end

--- Demonstrate  polymorphism
function  Eg.poly(my)
  local dog,point,p1,p2
  dog={}
  function dog:new() 
    return Obj.new(self,"DOG",{coat='black',age=0}) end
  function dog:bark()  print(self.age) end
  point={}
  function point:new(o) 
    return Obj.new(self,"POINT",o) end
  function point:bark() print(self.y) end
  p1 = point:new{x=10,y=100}
  p2 = point:new{x=20, y=dog:new()}
  point:new{x=20,y=-10}:bark()
  dog:new():bark()
  print(p2) end

-- --------------------------------------------
Eg.all(Sys.cli(MY,arg))
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
