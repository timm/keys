package.path = '../src/?.lua;' .. package.path

local files=require"files"

do 
  for row in files.csv("../data/weathernom.csv") do 
    assert(5 == #row, "row wrong length")
    assert("string" == type(row[1]), "wrong type") end 
end
