package.path = '../src/?.lua;' .. package.path
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

local _=require"list"; local eq=_.eq

local a={10,{d=100},{c=30},{1,{2,{3,{4,6}}}}}
local b={10,{d=100},{c=30},{1,{2,{3,{4,6}}}}}
local c={10,{d=100},{c=30},{1,{2,{3,{4,10 -- difference here
                           }}}}}
assert(    eq(a,b))
assert(not eq(a,c))

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
