local Skip = {}
local obj = require"obj"

-- **new(at : int=0, name : string="") : Skip**     
function Skip:new(at, name)  
  return obj(self,"Skip",{n=0, name=name or "", at=at or 0}) end

-- **add(x : atom)**  
-- Update. Sort of. Actually, do nothing.
function Skip:add(x)
  if x ~= "?" then self.n = self.n + 1 end
  return  x end

return Sym
