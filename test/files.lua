package.path = '../src/?.lua;' .. package.path

local fls=require"files"

do 
  for row in fls.csv("../data/weathernom.csv") do 
    assert(5 == #row, "row wrong length")
    assert("string" == type(row[1]), "wrong type") end end

do 
  local n=0
  for row in fls.csv("../data/auto93.csv") do 
    n = n + 1
    if n> 1 then  assert(type(row[1]) == "number",row[1]) end end end
