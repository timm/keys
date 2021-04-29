#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Misc lua routines.     
-- (c) Tim Menzies, 2021  
-- [![DOI](https://zenodo.org/badge/318809834.svg)](https://zenodo.org/badge/latestdoi/318809834) 
-- ![](https://img.shields.io/badge/language-lua,bash-orange)     
-- ![](https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet)
-- [![Build Status](https://travis-ci.com/timm/keys.svg?branch=main)](https://travis-ci.com/timm/keys)
-- [![](https://img.shields.io/badge/license-mit-lightgrey)](http://github.com/timm/keys/blob/main/LICENSE.md)    
-- [docs](http://menzies.us/keys/index.html) | [github](http://github.com/timm/keys/blob/main/README.md)

-- ---------------------------------------------
local m={}

-- Return something, unchanged
function m.same(x) return x end

-- Return any item in a list
function m.any(a) return a[1 + math.floor(#a*math.random())] end

-- Return t1 with t2 added in.
function m.add(t1,t2,   t3)
  t3 = {}
  for _,y in pairs(t1) do t3[#t3+1]= m.copy(y) end
  for _,y in pairs(t2) do t3[#t3+1]= m.copy(y) end
  return t3 end

-- Returns t if x is in t
function m.has(x,t)
  for _,y in pairs(t) do if y==x then return true end end end

-- Returns all combinations of  `s`
function m.powerset(s)
  local t = {{}}
  for i = 1, #s do
    for j = 1, #t do t[#t+1] = {s[i],table.unpack(t[j])} end end
  return t end

-- Time a function
function m.watch(f,n)
  n = n or 10
  local x = os.clock()
  for _ = 1,n do f() end
  m.printf("%5.4f secs", (os.clock() - x)/n) end

-- Split the string `s` on separator `c`, defaults to "." 
function m.split(s,     c,t)
  t, c = {}, c or ","
  for y in string.gmatch(s, "([^" ..c.. "]+)") do t[#t+1] = y end
  return t end

-- Deep copy
function m.copy(obj,   old,new)
  if type(obj) ~= 'table' then return obj end
  if old and old[obj] then return old[obj] end
  old, new = old or {}, {}
  old[obj] = new
  for k, v in pairs(obj) do new[k] = m.copy(v, old) end
  return new end

-- Object creation, add a unique id, bind to metatable, maybe set some initial values.
m._id=0
function m.isa(klass,inits,      new)
  new = m.copy(klass or {})
  for k,v in pairs(inits or {}) do new[k] = v end
  setmetatable(new, klass)
  klass.__index = klass
  m._id = m._id + 1
  new._id = m._id
  new._isa = klass
  return new end 

-- Iterate on keys in sorted order
function m.order(t,  i,keys)
  i,keys = 0,{}
  for key,_ in pairs(t) do keys[#keys+1] = key end
  table.sort(keys)
  return function ()
    if i < #keys then
      i=i+1; return keys[i], t[keys[i]] end end end 

-- "C"-like printf
function m.printf(...) print(string.format(...)) end

-- Simple print of a flat table
function m.o(z,pre) print(m.ooo(z,pre)) end

-- Simple translation table to string.
function m.ooo(z,pre,   s,c) 
  s, c = (pre or "")..'{', ""
  for _,v in m.order(z or {}) do s= s..c..tostring(v); c=", " end
  return s..'}' end

-- Nested translation table to string.
-- Don't show private slots (those that start with `_`);
-- show slots in sorted order;
-- if `pre` is specified, then  print that as a prefix.
function m.oo(t,pre,    indent,fmt)
  pre    = pre or ""
  indent = indent or 0
  if(indent==0) then print("") end
  if indent < 10 then
    for k, v in m.order(t or {}) do
      if not (type(k)=='string' and k:match("^_")) then
        if not (type(v)=='function') then
          fmt = pre..string.rep("|  ",indent)..tostring(k)..": "
          if type(v) == "table" then
            print(fmt)
            m.oo(v, pre, indent+1)
          else
            print(fmt .. tostring(v)) end end end end end end

-- Warn about locals that have escaped into the global space
function m.rogues(    ignore,match)
  ignore = {
    jit=1, utf8=1,math=1, package=1, table=1, coroutine=1, bit=1, 
    os=1, io=1, bit32=1, string=1, arg=1, debug=1, _VERSION=1, _ENV=1, _G=1,
    tonumber=1, next=1, print=1, collectgarbage=1, xpcall=1, rawset=1,
    load=1, rawequal=1, tostring=1, assert=1, _assert=1, ipairs=1,
    warn=1,
    setmetatable=1, type=1, loadfile=1, require=1, error=1, rawlen=1,
    getmetatable=1, pcall=1, dofile=1, select=1, rawget=1, pairs=1}
  for k,v in pairs( _ENV ) do
    if  not ignore[k] then
      print("-- warning, rogue variable ["..k.."]") end end end 

-- Return each row, split on ",", numstrings coerced to numbers,
-- kills comments and whitespace.
function m.csv(file,     stream,tmp,t)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function()
    if tmp then
      tmp = tmp:gsub("[\t\r ]*","") -- no whitespace
               :gsub("#.*","") -- no comemnts
      t   = m.split(tmp) 
      tmp = io.read()
      if #t > 0 then 
        for j,x in pairs(t) do t[j] = tonumber(x) or x end
        return t end
    else
      io.close(stream) end end end

-- -----------------------------------
-- And finally...

return m
