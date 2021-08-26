local Sample={}
local obj = require"obj"
local Num = require"num"

function Sample:new()
  return obj(self, "Sample",{a=2,num=Num:new()}) end

return Sample
