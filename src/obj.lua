#!/usr/bin/env lua
--vim: filetype=lua ts=2 sw=2 sts=2 et :

dumps = require "dumps"

local Obj = {}

local id=0
function Obj.new(self, name, new)
  new = setmetatable(new or {}, self)
  self.__tostring = dumps.dump 
  self.__index    = self
  self._name      = name
  id = id + 1
  new._id = id
  return new end

return Obj
