#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Object support code
-- (c) Tim Menzies, 2021   

-- -----------------------------
local isa, _id, copy

-- Object creation, add a unique id, bind to metatable, 
-- maybe set some initial values.
_id=0
function isa(klass,inits,      new)
  new = copy(klass or {})
  for k,v in pairs(inits or {}) do new[k] = v end
  setmetatable(new, klass)
  klass.__index = klass
  _id = _id + 1
  new._id = _id
  new._isa = klass
  return new end 

-- Deep copy
function copy(obj,   old,new)
  if type(obj) ~= 'table' then return obj end
  if old and old[obj] then return old[obj] end
  old, new = old or {}, {}
  old[obj] = new
  for k, v in pairs(obj) do new[k] = copy(v, old) end
  return new end

-- -----------------------------
-- And finally...

return {isa=isa, copy=copy}

-- -----------------------------
-- ## Notes
-- Our object system supports encapsulation, polymorphism, 

