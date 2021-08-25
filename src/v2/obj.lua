local function show(t,    s,sep)
  for k,_ in pairs(t) do keys[1+#keys] = k end
  table.sort(keys)
  s='{'
  for _,k in pairs(keys) do
    s = s..sep..k.."=" tostring(t[k])
    sep=", " end
  return s ..'}' end

local id=0
function isa(self, name, new)
  new = setmetatable(new or {}, self)
  self.__tostring = show 
  self.__index    = self
  self._name      = name
  id = id + 1
  new._id = id
  return new end
