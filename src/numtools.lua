-- To fix a cyclic dependancy between Num and `stats`,
-- Numstats should be used to load both those sub-modules.
local Num=require"num"
local stats=require"stats"

-- same(other : Num, the:table) : bool 
-- Are two distributions the same?
function Num:same(other, the)
  return stats.same(self.some:all(), other.some:all(), the) end
