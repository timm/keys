#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

----------------------------------------------------
--- Meta
-- @section 
local _id  = 0
local Meta ={}

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
    s=s .. sep .. tostring(k).."="..tostring(o[k])
    sep=", " end
  return s.."}" end

--- Recursively, convert a table to a string of key, val pairs.
function Tab.rump(t,pre,    indent)
  local pre, indent = pre or "", indent or 0
  if indent < 10 then
    for k, v in pairs(t or {}) do
      if not (type(k)=='string' and k:match("^_")) then
        local fmt= pre..string.rep("|  ",indent)..tostring(k)..": "
        if type(v) == "table" then
          print(fmt)
          Tab.rump(v, pre, indent+1)
        else
          print(fmt .. tostring(v)) end end end end end

--- Return all subsets of  table `s` (including empty table)
function Tab.subsets(s)
  local t = {{}}
  for i = 1, #s do
  for j = 1, #t do t[#t+1] = {s[i],table.unpack(t[j])} end end
  return t end

--- Ensure `t` has sublists for keys. Increment `x.id` in innermost.
function Tab.incs(t, keys)
  local key,new
  for i = 1, (#keys-1) do
    key    = keys[i]
    t[key] = t[key] or {}
    t      = t[key] 
  end
  key = keys[#keys]
  new = 1 + (t[key] or 0) 
  t[key] = new
  return new end

--- Return  the  count of `keys` in `t` (default value is zero).
function Tab.has(t, keys)
  local key,new
  for i = 1, (#keys-1) do
    key = keys[i]
    t   = t[key]
    if not t then return 0 end 
  end
  key = keys[#keys]
  return t[key] or 0 end

--- deep compare  of contents
function Tab.eq(t1,t2)
  local ty1,ty2 = type(t1), type(t2)
  if ty1 ~= ty2 then return false end
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
  for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not Tab.eq(v1,v2) then return false end end
  for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not Tae.eq(v1,v2) then return false end end
  return true end

----------------------------------------------------
--- File I/O
-- @section 
local File={}

--- Iterate over lines, split by commas.
-- @param file string for the file name
-- @return nil
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
-- @section OO
local Obj={}

--- Objects can have a name, and can print themselves
-- @param name string
-- @param t  table
-- @return  t, attached to a metatable
function Obj:new(name, new)
  local new = new or {}
  setmetatable(new, self)
  self.__index = self
  self.__tostring = function(x)  return Tab.dump(x) end
  self._name =name
  return new end

----------------------------------------------------
--- System tools
-- @section 
local Sys={}

--- Search command line for flags matching keys in `want`.
function Sys.cli(want, got, usage)
  for k,v in pairs(got) do
    local flag=v:sub(2,#v)
    if     flag == "h" 
    then   print(usage); os.exit()
    elseif want[flag] ~=  nil then 
      if v:sub(1,1) == "+" 
      then want[flag] = true 
      else want[flag] = tonumber(got[k+1]) or got[k+1] end end end 
  return want end

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
return {meta=Meta, tab=Tab, file=File, obj=Obj, sys=Sys}
