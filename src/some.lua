#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Reservoir sampling
-- (c) Tim Menzies, 2021   

-- -----------------------------
local Some={_is="Some", max=256, n=0, unordered=true, _has={}}

local r=math.random

-- <a name=reservoir>
-- Keep the  first  (say) `max=256` numbers,
-- After which time, new numbers replace old numbers in the reservoir at probability
--`max/n` (where `n` is the total number of  numbers  seen so far);
function Some:add(x) 
  self.n = self.n + 1
  local pos 
  if   #self._has < self.max 
  then pos = #self._has + 1 
  else if   r() < self.max/self.n 
       then pos = 1+(r()*#self._has)//1 end end
  if pos then 
    self._has[pos]=x
    self.unordered=true end end 

-- Ensure the returned list of numbers is sorted.
function Some:has() 
  if self.unordered then table.sort(self._has) end
  self.unordered=false
  return self._has end

-- Ensure the returned list of numbers is sorted.
function Some:sd()
  local n, tmp = #self._has, self:has()
  return (tmp[(.9*n)//1] - tmp[(.1*n)//1])/2.56 end

-- -----------------------------
-- And finally...
return Some
