local _=require"list"; local eq=_.eq

local a={10,{d=100},{c=30},{1,{2,{3,{4,6}}}}}
local b={10,{d=100},{c=30},{1,{2,{3,{4,6}}}}}
local c={10,{d=100},{c=30},{1,{2,{3,{4,10 -- difference here
                           }}}}}
assert(    eq(a,b))
assert(not eq(a,c))
