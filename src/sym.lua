#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Column to summarize `Sym`bolic columns.   
-- Tim Menzies, license 2021, MIT     

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
