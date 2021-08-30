local rand,randi,Seed

-- **randi(?lo : int, ?hi : int) : int**  
-- Return an int between `lo`  and `hi` (default 0..1).
function randi(lo,hi) 
  return math.floor(rand(lo,hi)) end

-- **rand(?lo : num, ?hi : num) : float**   
-- Return a float between `lo`  and `hi` (default 0..1).
function rand(lo,hi,     mult,mod)
  lo,hi = lo or 0, hi or 1
  mult, mod = 16807, 2147483647
  Seed = (mult * Seed) % mod 
  return lo + (hi-lo) * Seed / mod end 

-- **srand(?s : int)**   
-- Reset random number seed to `s` or some system default. 
local function srand(s) 
  Seed = s or 10013 end

-- ------------------------------------------
-- Start-up action.
srand()
return {srand=srand, randi=randi, rand=rand}
