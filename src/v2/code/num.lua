local Num={}
local obj=require"obj"

function Num:new()
  return obj(self,"Num", {
      n=0,at=0,name="fred"}) end

return Num
