-- **rnd(num : num, ?decimals : num=0) : num**  
-- Return `num` rounded to `decimals` places.
local function rnd(num, decimals,      mult)
  mult = 10^(decimals or 0)
  return math.floor(num * mult + 0.5) / mult end

return {rnd=rnd}
