package.path = '../src/?.lua'

local _=require"rand";  local srand,rand,randi = _.srand,_.rand,_.randi
local _=require"list";  local sort,pump = _.sort, _.pump
local _=require"maths"; local rnd  = _.rnd

srand(1)
local a={}
for i=1,10 do a[1+#a] = rnd(rand(),3) end 
assert( .047 == sort(a)[2], "bad rand" )

do
  local out = {}
  for i=1,64 do out[1+#out] = randi(1,4)  end
  out = sort(out)   
  assert(1==out[1] and 4==out[#out], "range not explored")
end 

