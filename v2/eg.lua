#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

local l=require("lib")
local Meta,Tab,File,Obj,Sys=l.meta,l.tab,l.file,l.obj,l.sys

----------------------------------------------------
--- Unit  tests
-- @section Eg
local Eg={}

--- Run examples 
function Eg.all(my)
  for k,v in pairs(Eg) do 
    if   k ~="all" and (my.todo==k or my.todo=="")
    then v(my) end end end 

--- Dump options
function Eg.dump(my) print(Tab.dump(my))  end

--- Print usage
function Eg.hi(my) print("rast v1.0. usage:  ./rast.lua -h") end
  
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

----------------------------------------------------
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
return Eg
