package.path = '../src/?.lua;' .. package.path

local Sym=require"sym"

do
  local s = Sym:new()
  for _,x in  pairs { "c","a","a","a","a","b","b"} do s:add(x) end
  local e= s:var()
  assert('a' == s.mode)
  assert(1.378  <= e and  e <=1.38, "bad entropy") 
end     

