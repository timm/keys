-- # class Sample
-- |**Does** | 1      |: stores some rows|
-- |---------|-------:|------------------|
-- |         | 2      |: summarizes the rows in columns|
-- |**Has**  | cols   |: all the columns|  
-- |         | keep   |: if true then keep input row into rows|
-- |         | klass  |: the class column (if there is  one)|
-- |         | rows   |: list of rows|
-- |         | x      |: all the independent columns   
-- |         | y      |: all the dependent columns|  
-- |**Uses** |        |: [Num](num.html), [Skip](skip.html), [Sym](sym.html)|   
local Sample={}
local Num = require"num"
local Sym = require"sym"
local Skip= require"skip"
local obj = require"obj"
local csv = require("files").csv 
local lst = require("list")
local sfmt = require("strings").sfmt
local isKlass, isY, isX, isNum, isSym, isSkip, isWhat

-- **new(?init : table = {}) : Sample**     
function Sample:new(inits,       new)
  new = obj(self,"Sample",
            {rows={},keep=true,cols={},names={},x={},y={}})
  for _,row in pairs(inits or {}) do new:add(row) end  
  return new end

-- Structure of the column headers.
function isSkip(s)  return s:find("?") end
function isKlass(s) return s:find("!") end
function isNum(s)   return s:sub(1,1):match("[A-Z]") end
function isY(s)     return s:find("+") or s:find("-") or isKlass(s) end
function isWhat(s)  
  return isSkip(s) and Skip or (isNum(s) and Num or Sym) end

-- **add(t : table)**    
-- If this is the first `row`, create the header. Else, add new data.
function Sample:add(t)
   if #self.names > 0 then self:data(t) else self:header(t) end end

-- **better(row1 :table, row2 :table) :boolean**     
-- Zitler's [continuous domination
-- indicator](https://doi.org/10.1007/978-3-540-30217-9_84).  To check
-- if `Row1` is better than `row2`, this function runs two "whatif" queries  (that
-- jump from one individual to another or back again).  According to
-- Zitler, the thing we like best is the thing losses least across those
-- whatifs.
function Sample:better(row1,row2,   w,s1,s2,n,a,b,s1,s2)
  what1, what2, n = 0, 0, #self.y
  for _,col in pairs(self.y) do
    w    = col.w -- w = (1,-1) if (maximizing,minimizing)
    a    = col:norm(row1[col.at])
    b    = col:norm(row2[col.at])
    what1= what1 - math.exp(1)^(col.w * (a - b) / n)
    what2= what2 - math.exp(1)^(col.w * (b - a) / n) end
  return what1 / n < what2 / n end

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
  for _,col in pairs(self.cols) do -- update column summaries
    col:add( t[col.at] ) end
  if self.keep then  -- update rows
    self.rows[ 1 + #self.rows ] = t end 
  return row end

-- **dist(row1 : table, row2 : table, the : config) : num**  
-- Apply Aha's instance-based distance algorithm,
-- [section 2.4](https://link.springer.com/content/pdf/10.1007/BF00153759.pdf).
function Sample:dist(row1,row2,the,       a,b,d,n)
  d,n = 0,1E-32
  for _,col in pairs(self[the.cols]) do
    n   = n + 1
    a,b = row1[col.at], row2[col.at]
    if    a=="?" and b=="?" 
    then  d = d + 1
    else  d = d + col:dist(a,b)^the.p end end
  return (d/n)^(1/the.p) end

-- **div(rows : table, the : options) : table,table**    
-- Split rows via their distance to two faraway points, 
function Sample:div(rows,the,         one,two,three,c,a,b,l,r)
  one = lst.any(rows)
  two = self:faraway(one, the, rows)
  three = self:faraway(two, the, rows)
  c   = self:dist(two, three, the)
  tmp = {}
  for _,row in pairs(rows) do
    a = self:dist(row, two, the)
    b = self:dist(row, three, the)
    tmp[1+#tmp] = {row= row, 
                   x  = (a^2 + c^2 - b^2) / (2*c)} 
  end
  l,r = {},{}
  for i,rowx in pairs(lst.keysort(tmp,"x")) do
    table.insert( i<=#rows//2 and l or r, rowx.row) end
  return l,r end

-- **divs(the : options) : [table]**    
-- Recursive divide rows down to size #rows^(the.enough=.5).
-- Return  one table per leaf.
function Sample:divs(the,    out, enough,run)
  function run(rows,lvl,      pre,l,r)
    if the.loud then  -- very useful debugging aid 
      pre = "|.. ";print(pre:rep(lvl)..tostring(#rows))
    end
    if #rows < enough then
      out[#out+1] = self:clone(rows)
    else 
      l,r = self:div(rows, the,cols)
      run(l, lvl+1)
      run(r, lvl+1)  end
  end --------------------------------
  out = {}
  enough = 2*(#self.rows)^the.enough
  run(self.rows, 0)
  return out end

-- **faraway(row : table, the : config, rows : table) : table**    
-- Return  a row that is the.far-.9 distant from 
-- row across a sample of the.samples=256 rows
function Sample:faraway(row,the,rows,      out,all)
  all = self:neighbors(row,the, 
              lst.shuffle(rows, the.samples)) 
  return all[the.far*#all // 1].row end

-- **from(file : str) : self**   
-- Load rows from file into `self.
function Sample:from(file) 
  for row in csv(file) do self:add(row) end 
  return self end

-- **header(t : table)**    
-- Read the magic symbols, make the appropriate columns,
-- store them in the right  places.
function Sample:header(t,   what,new,tmp)
  self.names = t
  for at,name in pairs(t)  do
    what = isWhat(name)
    new  = what:new(at,name) 
    self.cols[1+#self.cols] = new
    if not isSkip(name) then
      tmp= self[isY(name) and  "y" or "x"]
      tmp[ 1+#tmp ] = new
      if isKlass(name) then self.klass = new end end end end

--  **knn(row : table, the : config)**   
-- Return some conclusion  from the neighbors of `row`.
function Sample:knn(row,the,     stats,kadd,all,one)
  stats = Sym:new()
  all= self:neighbors(row, the, self.rows)
  for i = 2,the.knn do 
    one = all[i].row
    stats:add( one[self.klass.at] ) end
  kadd={mode=function() return stats.mode end}
  return kadd[the.kadd]() end

--  **mid()**     
-- Central tendancy
function Sample:mid()
  return lst.map(self.cols,function(z) return z:mid() end) end

-- **neighbors(row1 : table, the : options) : num**    
function Sample:neighbors(row1,the,rows,    t)
  t={}
  for _,row2 in pairs(rows or self.rows) do
     t[1+#t]= {row=row2, dist=self:dist(row1,row2,the)} end 
  return lst.keysort(t,"dist") end

-- **y(fmt)**    
-- Goal vars
function Sample:ys(fmt)
  fmt = fmt or " %5.2f"
  return lst.map(self.y,
           function(z) return sfmt(fmt, z:mid()) end) end

--  ------------
return Sample
