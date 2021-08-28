-- Reservoir sampler. When  it fills up,
-- add a random sample of what's next (throwing
-- away random items as required).

local Some={}
local obj  = require"obj"
local rand = require("rand").rand

-- **Some:new(?most : int) : Some**  
function Some:new(most)
  return obj(self,"Some",{n=1,_all={},sorted=false,most=most or 256}) end

--  **Some:add(x : any)**   
-- If full, replace anything, picked at random.
function Some:add(x)
  if x ~= "?" then
    self.n = self.n + 1
    if #self._all < self.most then 
      self.sorted = false
      self._all[1 + #self._all] = x
    elseif rand() < #self._all/self.n then 
      self.sorted = false 
      self._all[ math.floor(1+ rand()*#self._all) ] = x end end 
  return x end

-- **Some:all() : table**   
-- Return contents, sorted.
function Some:all()
  if not self.sorted then table.sort(self._all) end
  self.sorted = true
  return self._all end

-- **Some:mid() : any**   
-- Return the median point.
function Some:mid()
  return self:per(.5) end

-- **Some:per(p : float) : any**   
-- Return the `p`-th percentile from `self.some`.
function Some:per(p,    a)
  a = self:all()
  return a[math.max(1,math.floor(#a*(p or .5)))] end

-- **Some:sd() : num**   
-- Return the  standard deviation of this sample.
function Some:sd()
  return ( self:per(.9) - self:per(.1) ) / 2.56 end

-- ----------------
return Some
