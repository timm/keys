
local Sample=require"sample"
require("rand").srand(0) 
local the = require"cli"
local lst = require"list"
local rnd = require("maths").rnd
local s   = Sample:new():from("../data/auto93.csv")

do
  local col=s.cols[1]
  assert(col.lo == 3   , "wanted 3")
  assert(col.hi == 8   , "wanted 8")
  assert(col.n  == 398 , "wanted 3") end

do
 local rows = lst.shuffle(s.rows, 32)
 for _,row in pairs(rows) do
   local t = s:neighbors(row, the) 
   assert(t[2].dist < t[#t].dist,"near not far") end end 

do
 s = Sample:new():from("../data/weathernom.csv")
 local n,yes=0,0
 local rows = lst.shuffle(s.rows)
 for _,row in pairs(rows) do
   local x = s:knn(row, the) 
   n = n + 1
   if x==row[s.klass.at] then yes=yes+1 end  end 
 print(yes/n)
end



