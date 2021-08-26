package.path = '../src/?.lua;' .. package.path
local the=require"the"


for _,f in pairs(arg) do
   re
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

local _=require"rand";  local rand,srand = _.rand, _.srand
local _=require"list";  local pump,sort  = _.pump, _.sort
local _=require"maths"; local rnd        = _.rnd

srand(1)
local a={}
for i=1,10 do a[1+#a] = rnd(rand(),3) end 
assert( .047 == sort(a)[2] )

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
