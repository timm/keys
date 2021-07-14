#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

local Lib=require("lib")
local Keys=require("keys0")

----------------------------------------------------
--- Unit  tests
local Eg={}
Eg.go = {}

--- Run examples 
function Eg.all(my)
  for k,v in pairs(Eg.go) do 
    if   go.x==k or go.x==""
    then v[2](my) end end end 

Eg.go.dump = {
  "show current options",  
  function (my)
    print(Lib.tab.dump(my))  end}

Eg.go.sample = {
  "compute frequency counts for discrete data files", 
  function(my) 
    local t= Lib.file.count(Lib.file.csv("../data/vote.csv") )
    Lib.tab.rump(t.attrs) 
    end}

Eg.go.hi = {
  "print usage", 
  function (my) 
     print("rast v1.0. usage:  ./rast.lua -h") end} 
  
Eg.go.csv = {
  "show rows in a file", 
  function (my) 
      for x in Lib.file.csv("../data/auto93.csv") do 
         Lib.Tab.pump(x) end end }

Eg.go.poly = {
  "demonstrate polymorphism", 
  function(my)
    local dog,point,p1,p2
    dog={}
    function dog:new() 
      return Lib.obj.new(self,"DOG",{coat='black',age=0}) end
    function dog:bark()  print(self.age) end
    point={}
    function point:new(o) 
      return Lib.obj.new(self,"POINT",o) end
    function point:bark() print(self.y) end
    p1 = point:new{x=10,y=100}
    p2 = point:new{x=20, y=dog:new()}
    point:new{x=20,y=-10}:bark()
    dog:new():bark()
    print(p2) end}

----------------------------------------------------
Eg.all( Lib.sys.cli( Keys.my, arg, Keys.usage ))
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
