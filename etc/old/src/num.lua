#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Place to summarize `Num`eric columns.       
-- (c) Tim Menzies, 2021     

-- -----------------------------
local Num = {_is="Num", at=0, txt="", n=0, mu=0, sd=0, m2=0, sum=0,
             lo=1e32,  hi=-1e32, _all={},ok=false}

-- Add a number, update `mu`, `sd`, `lo`, `hi`.
function Num:add(x)
  self._all[#self._all+1] = x 
  self.ok=false
  self.sum = self.sum + x
  local d = x - self.mu
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x-self.mu)
  self.sd = self.n<2  and 0 or (self.m2<0 and 0 or ((self.m2/self.n)^0.5))
  self.lo = math.min(self.lo, x)
  self.hi = math.max(self.hi, x) end

-- Synonyms:  the middle and spread of a set of symbol are the mean and standard deviation

function Num:mid(x) return self.mu end
function Num:spread(x) return self.sd end

function Num:some(m)
  if not self.ok then table.sort(self._all) end
  self.ok=true
  if not m then return self._all end
  local out={}
  for i= 1,#(self._all),math.max(1, #(self._all)//m) do 
    out[#out+1] = self._all[i] end
  return out end

-- Statistical tests
function Num:different(them,my)
  local xs,ys = self:some(my.some), them:some(my.some)
  return not cliffsDelta(xs,ys) and bootstrap(xs,ys,my.b, my.conf) end

-- Returns the `mu` delta, mitigated by the  joint variance.
function Num:delta(them,    y,z,e)
  y, z, e = self, them, 10^-64
  return (y.mu-z.mu) / (e+(y.sd/y.n+z.sd/z.n)^0.5) end

-- And finally...
return Num
