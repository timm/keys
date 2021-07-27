#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Random number utilities
-- (c) Tim Menzies, 2021   

-- -----------------------------
local seed, multipler, modulus, park_miller_randomizer, srand, rand

seed      = 10013
multipler = 16807.0
modulus   = 2147483647.0

function park_miller_randomizer()
  seed = (multipler * seed) % modulus -- cycle=2,147,483,646
  return seed / modulus end 

function srand(x) seed = x or 1 end
function rand(lo,hi) 
  lo,hi = lo or 0, hi or 1
  return lo + (hi-lo)*park_miller_randomizer() end

-- -----------------------------
-- And finally...

return {srand=srand, rand=rand}

-- ------------------------------
-- ## Notes
-- The standard LUA random number generator gives
-- different results on different platforms. This
-- code generates the same random  streams, on all platforms.
