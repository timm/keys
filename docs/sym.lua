-- Column to summarize `Sym`bolic columns.   
-- Tim Menzies, license 2021, MIT     
-- [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4728990.svg)](https://doi.org/10.5281/zenodo.4728990)
-- ![](https://img.shields.io/badge/language-lua,bash-orange)
-- ![](https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet)
-- [![Build Status](https://travis-ci.com/timm/keys.svg?branch=main)](https://travis-ci.com/timm/keys)
-- [![](https://img.shields.io/badge/license-mit-lightgrey)](http://github.com/timm/keys/blob/main/LICENSE.md)<br>   
-- [docs](http://menzies.us/keys/index.html) | [github](http://github.com/timm/keys/blob/main/README.md)

-- ---------------------------------------------

local Sym = {at=0, txt="", n=0, most=0, seen={}}

function Sym:add(x) 
  local tmp = (self.seen[x] or 0) + 1
  self.seen[x] = tmp 
  if tmp > self.most then self.most, self.mode = tmp,x end end 
    
function Sym:ent(   e)
  e=0
  for _,v in pairs(self.seen) do e = e-v/self.n*math.log(v/self.n,2) end
  return e end

function Sym:mid(x) return i.mode end 
function Sym:spread()  return self:ent() end

-- -----------------------------------
-- And finally...

return Sym
