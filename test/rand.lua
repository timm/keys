package.path = '../src/?.lua'

local _=require"rand";  local srand,rand = _.srand, _.rand
local _=require"list";  local sort = _.sort
local _=require"maths"; local rnd  = _.rnd

srand(1)
local a={}
for i=1,10 do a[1+#a] = rnd(rand(),3) end 
assert( .047 == sort(a)[2], "bad rand" )
