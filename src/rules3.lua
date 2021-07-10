#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :

local dump,new,inc,subsets,b4, csv,split,EG,L,MY

MY= {data="../data/auto93.csv",
     verbose=false,
     b4={}}
for k,_ in pairs(_ENV) do MY.b4[k]=k end
EG= {} -- examples
L = {} -- library

--- dump a flat table
function dump(o,   sep,s,keys)
  keys = {}
  for key,_ in pairs(o) do keys[#keys+1] = key end
  table.sort(keys)
  s,sep= (o._name or "").. "{",""
  for _,k in pairs(keys) do 
    s=s .. sep .. tostring(k).."= "..tostring(o[k])
    sep=", " end
  return s.."}" end

--- new objects can have a name, and can print themselves
function new(self,name, o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.__tostring = function(x)  return dump(x) end
  self._name =name
  return o end

-- inc a table value 
function inc(d,k,n) d[k] = (no or 1)  + (d[k] or 0) end

function subsets(s)
  local t = {{}}
  for i = 1, #s do
  for j = 1, #t do t[#t+1] = {s[i],table.unpack(t[j])} end end
  return t end

function split(s,     c,t)
  t, c = {}, c or ","
  for y in string.gmatch(s, "([^" ..c.. "]+)") do t[#t+1] = y end
    return t end

function csv(file,     stream,tmp,t)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function()
    if tmp then
      tmp = tmp:gsub("[\t\r ]*","") -- no whitespace
               :gsub("#.*","") -- no cots
      t = split(tmp)
      tmp = io.read()
      if #t > 0 then
        for j,x in pairs(t) do t[j] = tonumber(x) or x end
      return t end
    else
      io.close(stream) end end end

----------------------------------------------------------
--- EG.csv
-- just show contents
function EG.csv() 
  for x in L.csv("../data/auto93.csv") do L.show(x) end end

----------------------------------------------------------
--- EG.poly
-- demonstrate  polymorphism
function  EG.poly(    Dog,Point,p1,p2)
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

EG.poly()

---------------------------------
for k,v in pairs(arg) do
  local flag=v:sub(2,#v)
  if MY[flag]~=nil then 
     if v:sub(1,1) == "+" then
       MY[flag]= true 
     else
       MY[flag] = tonumber(arg[k+1]) or arg[k+1] end end end

print(dump(MY))

for k,_ in pairs(_ENV) do 
  if not MY.b4[k] then print("-- ROGUE ["..k.."]") end end
