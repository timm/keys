#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

local Lib=require("lib")
local Keys=require("keys0")

----------------------------------------------------
--- Unit  tests
local Eg={}

--- Run examples 
Eg.all = {
  "Run all (or some) examples.",
  function(my)
    local function one(k,v) 
      local pre="\n---------------------------"
      Lib.misc.color("green",pre .."\n-- "..k..pre); v[2](my) end 
    if my.x=="all" then
      for k,v in pairs(Eg) do 
        if k~="all" then one(k,v) end end
    else
      for k,v in pairs(Eg) do 
        if my.x==k or my.x=="" then one(k,v) end end end end }

Eg.dump = {
  "show current options",  
  function (my)
    print(Lib.tab.dump(my))  end}

Eg.sample = {
  "compute frequency counts for discrete data files", 
  function(my) 
    local t= Lib.file.count(Lib.file.csv("../data/vote.csv") )
    Lib.tab.rump(t) 
    end}

Eg.hi = {
  "print usage", 
  function (my) 
    print("rast v1.0. usage:  ./rast.lua -h") end} 
  
Eg.csv = {
  "show rows in a file", 
  function (my) 
    local n=0
    for x in Lib.file.csv("../data/auto93.csv") do 
      n = n + 1
      if n>20 then return end
      Lib.tab.pump(x) end end }

Eg.poly = {
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
Eg.all[2]( Lib.sys.cli( Keys.my, arg, Keys.usage, Eg ))
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
