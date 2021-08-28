-- # class Skip
-- |Does |: 1      |: mimics the  API of other columns.|
-- |---- |---      |------------------------------------------|
-- |     |: 2      |: no matter what I ask you do, do nothing |
-- |Has  |: n      |: counter of things seen so far|
-- |     |: at     |: column index|
-- |     |: name   |: column name|
local Skip = {}
local obj = require"obj"

-- **new(at : int=0, name : string="") : Skip**     
function Skip:new(at, name)  
  return obj(self,"Skip",{n=0, name=name or "", at=at or 0}) end

-- **add(x : atom)**  
function Skip:add(x)
  if x ~= "?" then self.n = self.n + 1 end
  return  x end

-- **dist(x : any, y : any) : num**  
function Skip:dist(x,y)
  return 0 end

-- **like(x : any, the : options) : num**  
function Skip:like(x,_)
  return 1 end

return Sym
