local Seed

-- ## randi(?lo:int, ?hi:int)
-- Return an int between `lo`  and `hi` (default 0..1).
local function randi(lo,hi) 
  return math.floor(rand(lo,hi)) end

-- ## randi(?lo:num, ?hi:num)
-- Return a float between `lo`  and `hi` (default 0..1).
local function rand(lo,hi,     mult,mod)
  lo,hi = lo or 0, hi or 1
  mult, mod = 16807, 2147483647
  Seed = (mult * Seed) % mod 
  return lo + (hi-lo) * Seed / mod end 

-- ## srand(?s:int)
-- Reset random number seed to `s` or some system default. 
local function srand(s) 
  Seed = s or 10013 end

srand()
return {srand=srand, randi=randi, rand=rand}
