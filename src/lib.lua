#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Misc lua routines.     
-- (c) Tim Menzies, 2021   

-- -----------------------------
local same, any, add, has, powerset, watch, split, printf
local copy, isa, order, prinf, o, oo, ooo, rogues, csv, mu, sd

-- Return something, unchanged
function same(x) return x end

-- Return any item a list
function any(a) return a[1 + math.floor(#a*math.random())] end

-- Return t1 with t2 added in.
function add(t1,t2,   t3)
  t3 = {}
  for _,y in pairs(t1) do t3[#t3+1]= copy(y) end
  for _,y in pairs(t2) do t3[#t3+1]= copy(y) end
  return t3 end

-- Returns t if x is in t
function has(x,t)
  for _,y in pairs(t) do if y==x then return true end end end

-- Returns all combinations of  `s`
function powerset(s)
  local t = {{}}
  for i = 1, #s do
    for j = 1, #t do t[#t+1] = {s[i],table.unpack(t[j])} end end
  return t end

-- Time a function
function watch(f,n)
  n = n or 10
  local x = os.clock()
  for _ = 1,n do f() end
  printf("%5.4f secs", (os.clock() - x)/n) end

-- What is the mean of a list?
function mu(t,   sum) 
  sum = 0
  for _,x in pairs(t) do sum=sum+x end
  return sum/#t end

-- <a name=sd>
-- The  standard deviation of a list of numbers is
-- the square root of the sum of (each item minus the mean)<sup>2</sup> divided
-- by the size minus one.

function sd(t,   sum,m,tmp) 
  local tmp,m = 0,mu(t)
  for _,x in pairs(t) do tmp = tmp+(m-x)^2 end
  return (tmp/(#t-1))^0.5 end

-- Cut the string `s` on separator `c`, defaults to "." 
function split(s,     c,t)
  t, c = {}, c or ","
  for y in string.gmatch(s, "([^" ..c.. "]+)") do t[#t+1] = y end
  return t end

-- Deep copy
function copy(obj,   old,new)
  if type(obj) ~= 'table' then return obj end
  if old and old[obj] then return old[obj] end
  old, new = old or {}, {}
  old[obj] = new
  for k, v in pairs(obj) do new[k] = copy(v, old) end
  return new end

-- Object creation, add a unique id, bind to metatable, 
-- maybe set some initial values.
local _id=0
function isa(klass,inits,      new)
  new = copy(klass or {})
  for k,v in pairs(inits or {}) do new[k] = v end
  setmetatable(new, klass)
  klass.__index = klass
  _id = _id + 1
  new._id = _id
  new._isa = klass
  return new end 

-- Iterate on keys in sorted order
function order(t,  i,keys)
  i,keys = 0,{}
  for key,_ in pairs(t) do keys[#keys+1] = key end
  table.sort(keys)
  return function ()
    if i < #keys then
      i=i+1; return keys[i], t[keys[i]] end end end 

-- "C"-like printf
function printf(...) print(string.format(...)) end

-- Simple print of a flat table
function o(z,pre) print(ooo(z,pre)) end

-- Simple translation table to string.
function ooo(z,pre,   s,c) 
  s, c = (pre or "")..'{', ""
  for _,v in order(z or {}) do s= s..c..tostring(v); c=", " end
  return s..'}' end

-- Nested translation table to string.
-- Don't show private slots (those that start with `_`);
-- show slots in sorted order;
-- if `pre` is specified, then  print that as a prefix.
function oo(t,pre,    indent,f)
  pre    = pre or ""
  indent = indent or 0
  if(indent==0) then print("") end
  if indent < 10 then
    for k, v in order(t or {}) do
      if not (type(k)=='string' and k:match("^_")) then
        if not (type(v)=='function') then
          f = pre..string.rep("|  ",indent)..tostring(k).." "
          if type(v) == "table" then
            print((v._is or "")..":"..f)
            oo(v, pre, indent+1)
          else
            print(f .. tostring(v)) end end end end end end

-- Warn about locals that have escaped into the global space
function rogues(    ignore)
  ignore = {
    jit=1, utf8=1,th=1, package=1, table=1, coroutine=1, bit=1, math=1,
    os=1, io=1, bit32=1, string=1, arg=1, debug=1, _VERSION=1, _ENV=1, _G=1,
    tonumber=1, next=1, print=1, collectgarbage=1, xpcall=1, rawset=1,
    load=1, rawequal=1, tostring=1, assert=1, _assert=1, ipairs=1,
    warn=1,
    setmetatable=1, type=1, loadfile=1, require=1, error=1, rawlen=1,
    getmetatable=1, pcall=1, dofile=1, select=1, rawget=1, pairs=1}
  for k,v in pairs( _ENV ) do
    if  not ignore[k] then
      print("-- warning, rogue variable ["..k.."]") end end end 

-- Return each row, split on ",", maybe coercing strings to numbers,
-- kills comments and whitespace.
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

-- -----------------------------------
-- And finally...

return {same=same, any=any, add=add, has=has,
        powerset=powerset, watch=watch, split=split,
        copy=copy, isa=isa, order=order, printf=printf,
        o=o, oo=oo, ooo=ooo, rogues=rogues, csv=csv,mu=mu,sd=sd}
        
