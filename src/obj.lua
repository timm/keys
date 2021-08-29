local List = require("list")

-- ## obj(self:table, name:str, new:t)
-- Return a new object of type `self`
-- with print `name` with fields `t`.
local function obj(self, name, new)
  new = setmetatable(new or {}, self)
  self.__tostring = List.dump 
  self.__index    = self
  self._name      = name
  return new end

return obj
