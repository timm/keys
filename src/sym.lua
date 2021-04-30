#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Place to summarize `Sym`bolic columns.   
-- (c) Tim Menzies, 2021.    

-- --------------------------------
local Sym = {at=0, txt="", n=0, most=0, seen={}}

-- Incremental symbol counts, maybe update `mode`.
function Sym:add(x) 
  local tmp = (self.seen[x] or 0) + 1
  self.seen[x] = tmp 
  if tmp > self.most then self.most, self.mode = tmp,x end end 
    
-- Synonyms:  the middle and spread of a set of symbol are the mean and standard deviation

function Sym:mid(x) return i.mode end 
function Sym:spread()  return self:ent() end

-- Entropy reports the effort required to recreate a signal.
function Sym:ent(   e)
  e=0
  for _,v in pairs(self.seen) do e = e-v/self.n*math.log(v/self.n,2) end
  return e end

-- -----------------------------------
-- And finally...

return Sym
