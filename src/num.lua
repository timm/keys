#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Place to summarize `Num`eric columns.       
-- (c) Tim Menzies, 2021     

local Num = {at=0, txt="", n=0, mu=0, sd=0, m2=0, 
             lo=1e32,  hi=-1e32, _all={}}

-- Add a number, update `mu`, `sd`, `lo`, `hi`.
function Num:add(x)
  self._all[#self._all+1] = x 
  local d = x - self.mu
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x-self.mu)
  self.sd = self.n<2  and 0 or (self.m2<0 and 0 or ((self.m2/self.n)^0.5))
  self.lo = math.min(self.lo, x)
  self.hi = math.max(self.hi, x) end

-- Synonyms:  the middle and spread of a set of symbol are the mean and standard deviation

function Num:mid(x) return self.mu end
function Num:spread(x) return self.sd end

-- And finally...
return Num
