-- Column to summarize `Num`eric columns.       
-- Tim Menzies, (c) 2021, MIT    
-- [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4728990.svg)](https://doi.org/10.5281/zenodo.4728990)
-- ![](https://img.shields.io/badge/language-lua,bash-orange)
-- ![](https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet)
-- [![Build Status](https://travis-ci.com/timm/keys.svg?branch=main)](https://travis-ci.com/timm/keys)
-- [![](https://img.shields.io/badge/license-mit-lightgrey)](http://github.com/timm/keys/blob/main/LICENSE.md)<br>   
-- [docs](http://menzies.us/keys/index.html) | [github](http://github.com/timm/keys/blob/main/README.md)

-- ---------------------------------------------

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
