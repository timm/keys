#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

--- Contrast set learning

--- @usage
local usage = [[
rast : Contrast set learning
(c) 2021 Tim Menzies timm@ieee.org, unlicense.org

The difference between things (in the same domain) is 
often shorter to describe than the things themselves.

USAGE: ./rast.lua [OPTIONS]

OPTIONS:

  -h            print help
  -data FILE    read data from FILE
  -goal STR     one of optimizer, monitor, explode
  +verbose      enable verbose mode
]] 

local MY={data   = "../data/auto93.csv"
         ,todo   = "hi"
         ,verbose= false}

----------------------------------------------------
--- Meta
-- @section 

local _id  = 0

--- Return a unique id
function Meta.id() _id = _id+1;  return _id end

----------------------------------------------------
--- LUA tables 
-- @section 

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

--- Return all subsets of  table `s` (including empty table)
function Tab.subsets(s)
  local t = {{}}
  for i = 1, #s do
  for j = 1, #t do t[#t+1] = {s[i],table.unpack(t[j])} end end
  return t end

--- Ensure `t` has sublists for keys. At `x.id`, add `x` to innermost.
function Tab.sets(t, keys, x)
  for  i=1,#keys do
    local key = keys[i]
    t[key] = t[key] or {}
    t = t[key] 
  end
  t[x.id] = x end

--- Ensure `t` has sublists for keys. Increment `x.id` in innermost.
function Tab.incs(t, keys)
  local key
  for  i=1,(#keys-1) do
    key = keys[i]
    t[key] = t[key] or {}
    t = t[key] 
  end
  key = keys[#keys]
  local new = 1 + (t[key] or 0) 
  t[key] = new
  return new end

----------------------------------------------------
--- File I/O
-- @section 
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
--- OO stuff
-- @section 
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
--- System tools
-- @section 
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
--- Row
-- @type Row
local Row={}

--- Numbers have standard deviation.
function Row:new(cells) 
  return Obj.new(self,"Row",{cells=cells, id=Meta.id()}) end

----------------------------------------------------
--- Rule
-- @type Rule
local Rule={}

local goal={}
function goal.optimize(b,r) return b^2 / (b+r)  end
function goal.monitor(b,r) return r^2 / (b+r)  end
function goal.explore(b,r) return 1  / (b+r) end

--- Numbers have standard deviation.
function Rule:new(t) 
  return Obj.new(self,"Rule",{
    tbl  = t.tbl,
    want = t.want,
    goal = t.goal or goal.optimize,
    init = t.init or nil}) end

----------------------------------------------------
--- Sample
-- @section Sample
local Sample={}

function Sample.read(src)
   local t={rows={},klasses={}, attrs={}}
   for lst in src do
     if   t.names 
     then row = Row:new(lst)
          t.rows[1 + #t.rows] = row
          local kl = lst[t.class]
          Tab.set1(t.classes, k, row)
          for pos,val in pairs(lst) do
            if val ~= "?" then
              Tab.has(t.attrs, val, {id=val,x={val,val}})
              Tab.has(t.all,        {id=val,x={attr,{val,val}}}) end end 
     else t.names = lst
          t.klass = #lst end end end

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
function Eg.dump(my)  print(Tab.dump(my))  end

--- Print usage
function Eg.hi(my)  print("rast v1.0. usage:  ./rast.lua -h") end
  
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
