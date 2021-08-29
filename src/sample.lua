-- # class Sample
-- |Does |: 1      |: stores some rows |
-- |---- |---      |------------------------------------------|
-- |     |: 2      |: summarizes the rows in columns |
-- |Has  |: cols   |: all the columns|  
-- |     |: keep   |: if true then keep input row into rows  |
-- |     |: rows   |: list of rows|
-- |     |: x      |: all the independent columns |  
-- |     |: y      |: all the dependent columns |  
local Sample={}
local Num = require"num"
local Sym = require"sym"
local Skip= require"skip"
local obj = require"obj"
local csv = require("files").csv 
local isKlass, isGoal, isNum, isSkip

-- **new(?init : table = {}) : Sample**     
function Sample:new(init,       new)
  new = obj(self,"Sample",
            {rows={},keep=true,cols={},names={},x={},y={}})
  for _,row in pairs(inits or {}) do new:add(row) end  
  return new end

-- Structure of the column headers.
function isKlass(s) return s:find("!") end
function isGoal(s)  return s:find("+") or s:find("-") or isKlass(s) end
function isNum(s)   return s:sub(1,1):match("[A-Z]") end
function isSkip(s)  return s:find("?") end

-- **add(t : table)**    
-- If this is the first `row`, create the header. Else, add new data.
function Sample:add(t)
   if #self.names > 0 then self:data(t) else self:header(t) end end

-- **clone(?inits : table={}) : Sample**    
-- Return a table with the same  structure as `self`.
-- If `inits` supplied, add that data to `new`.
function  Sample:clone(inits,    new)
  new = Sample:new({self.names})
  for _,row in pairs(inits or {}) do new:add(row) end
  return new end

-- **data(t : table)**   
-- Update the column summaries. Maybe  keep the new row.
function Sample:data(t,    row)
  for _,col in pairs(self.all) do t[col.at]=col:add( t[col.at] ) end
  if self.keep then self.rows[ 1 + #self.rows ] = t end 
  return row end

-- **dist(row1 : table, row2 : table, the : config) : num**  
function Sample:dist(row1,row2,the,       a,b,d,n)
  d,n = 0,1E-32
  for _,col in pairs(self.cols[the.cols]) do
    n   = n + 1
    a,b = row1[col.at], row2[col.at]
    if    a=="?" and b=="?" 
    then  d = d + 1
    else  d = d + col:dist(a,b)^the.p end end
  return (d/n)^(1/the.p) end

-- **header(t : table)**    
-- Read the magic symbols, make the appropriate columns,
-- store them in the right  places.
function Sample:header(t,   what,new,tmp)
  self.names=t
  for at,name in pairs(t)  do
    what = isSkip(name) and Skip or (isNum(name) and Num or Sym)
    new  = what:new(at,name) 
    self.all[1+#self.all] = new
    if not isSkip(name) then
      tmp= self[isGoal(txt) and  "y" or "x"]
      tmp[ 1+#tmp ] = new
      if isKlass(name) then self.klass = new end end end end

--  **knn(row : table, the : config)**   
-- Return some conclusion  from the neighbors of `row`.
function Sample:knn(row,the,     stats,kadd,all,one)
  stats = Sym:new()
  all= self:neighbors(row,the)
  for i = 1,the.knn do 
    one = all[i].row
    stats:add( one:klass() ) end
  kadd={mode=function() return stats.mode end}
  return kadd[the.kadd]()
end

-- **neighbors(row1 : table, the : options) : num**   
function Sample:neighbors(row1,the,    t)
  t={}
  for _,row2 in pairs(self.rows) do
     t[ 1+#t ] = {row=row2, dist=self:dist(row1,row2,the)} end 
  return sort(t,"dist") end

-- **read(file : str) : self**   
-- Load rows from file into `self.
function Sample:read(file) 
  for row in csv(file) do self:add(row) end 
  return self end
--  ------------
return Sample
