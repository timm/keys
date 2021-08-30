package.path = '../src/?.lua'

local Num=require"num"
local _=require"rand"; local srand,rand=_.srand, _.rand
srand(1)

do
  local n = Num:new()
  for i=1,10000 do n:add(rand()) end
  assert(0.288 < n.sd and n.sd < 0.289,"sd wrong") 
  assert(0.501 < n.mu and n.mu < 0.502,"mu wrong") 
end

do
  local n = Num:new()
  local t = {9,2,5,4,12,7,8,11,9,3,7,4,12,5,4,10,9,6,9.4} 
  for _,x in pairs(t) do n:add(x) end
  assert(3.074 < n.sd and n.sd < 3.075,"sd wrong") 
  assert(7.178 < n.mu and n.mu < 7.179,"mu wrong") 
end
