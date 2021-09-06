-- # category Range = _Nums_ or _Syms_
-- This code lets us treat numeric `Nums` and symbolic `Syms` ranges with the same
-- protocol. Also, for `Nums`, this code implements supervised discretization.
-- -----------------------------------------
-- |**Class**|Nums      |: category= data  |
-- |---------|---------:|------------------|
-- |**Does** | 1        |: unify  interface to numeric and symbolic ranges|
-- |         | 2        |: reports if a row can be in a range|
-- |         | 3        |: print details about this range|
-- |         | 4        |: explores lists of (x:num, y:sym), sorted on `num`|
-- |         | 5        |: find ranges that split the `x` values into not-small chunks|
-- |         | 6        |: prune ranges that do not change the `y` distribution|
-- |**Has**  | x :Num   |: info about the `x` values|
-- |         | y :Sym   |: info about the `y` values|
-- |         | at :num  |: column index of this range|
-- |         | name :str|: column name of this range|
-- |**Uses** |          |: [Num](num.html),   [Sym](sym.html)|    
-- ----------------------------------------- 
-- |**Class**|Syms      |: category= data  |
-- |---------|---------:|------------------|
-- |**Does** | 1        |: unify interface to numeric and symbols ranges|
-- |         | 2        |: reports if a row can be in a range|
-- |         | 3        |: print details abut this range|
-- |**Has**  | x :string|: the symbolic `x` value that defines this range|
-- |         | at :num  |: column index of this range|
-- |         | name :str|: column name of this range|
local Nums={}
local Syms={}
local Num = require"num"
local Sym = require"sym"
local obj = require"obj"
local sfmt = require("strings").sfmt
local prune,ranges
-- ------
-- ## Creation
function Nums(xs,ys,at,name)
   return obj(self,"Nums", {at=at or 0, name=name or "",
                   xs=xs or Num:new(), ys=ys or Sym:new()}) end 

function Syms(x,at,name)
   return obj(self,"Syms", {at=at or 0, name=name or "",x=x}) end

-- ------
-- ## Copy

-- **clone(?xs :Num, ?ys:Sym): Nums|Syms**   
-- return a range with the same name and column index
function Nums:clone(xs,ys) return Nums:new(xs, ys, self.at, self.name) end
function Syms:clone(xs,ys) return Syms:new(xs, ys, self.at, self.name) end

-- ------
-- ## Printing
function Nums:show(w,d,         f) 
   w,d=w or 5,d or 2
   f = sfmt("%%%s,%sf",w,d) -- format for width`w` and `d` decimals
   return sfmt("%s=["..f..".."..f.."]",self.name,self.xs.lo,self.xs.hi) end

function Syms:show(w,d,          s) 
   s=tostring(self.x)
   return   sfmt("%s=[%s]", self.name, s:sub(1,math.min(w,#s))) end

-- ------------------------------
-- ## Query

-- **holds(row :table, isFirst :boolean, isLast :boolean) :boolean)**    
-- Returns true if this row might be in this range.
-- Note that for `Nums`, being the first or last range is space case
function Nums:holds(row,isFirst,isLast,            x)
   x = row[self.at]
   if         x=="?"                               then return true 
   elseif isFirst and x <= self.xs.hi then return true 
   elseif isLast   and x >= self.xs.lo then return true
   else    return x>=self.xs.lo and x<=self.xs.hi end end

function Syms:holds(row, isFirst, isLast,      x)
   x = row[self.at]
   return x=="?" and true or x==self.x end

-- -----------
-- ## Discretization

-- **ranges(xys:{{num,str}}, tiny:num, enough:num, at:int, name:str): {range}**      
-- Make a new range when       
-- (1) there is enough left for at least one more range; and       
-- (2) the lo,hi delta in current range is not tiny; and   
-- (3) there are enough x values in this range; and      
-- (4) there is natural split here
function ranges(xys, tiny, enough,at,name,         now,out,x,y)
   while width <4 and width<#xy/2 do width=1.2*width end --grow small widths
   now = Nums:new(Num:new(),Sym:new(),at,name)
   out = {now}
   for j,xy in sort(xys,"x") do
      x,y = xy[1],xy[2]
      if j < #xys - enough then -- (1)
         if x ~= xys[j+1][1] then -- (2)
             if now.n > enough then -- (3)
                if now.hi - now.lo > tiny then -- (4)
                     now = now:clone()
                     out[ 1+#out ] = now end end end end
      now.xs.add(x)
      now.ys.add(y) end
   return prune(out) end

-- **prune(b4 :{{xs:Num,ys:Sym}}) :{{xs:Num,ys:Sym}}**      
-- Return a smaller version of `b4` (by subsuming ranges
-- that do not change the class distributions seen in `ys`)
function prune(b4,             j,tmp,n,a,b,cy)
   j, n, tmp = 1, #b4, {}
   while j<=n do
      a= b4[j]
      if j < n-1 then
         b= b4[j+1]
         ay,by,cy= a.ys, b.ys, merge(a.ys, b.ys)
         if cy:var() <= ay:var()*ay.n/c.n + by:var()*by.n/cy.n then
             a= a:clone(a.xs:merge(b.xs), cy)
             j = j + 1 end end
      tmp[1+#tmp] = a
      j = j + 1
   end
   return #tmp==#b4 and tmp or merge(tmp) end
      
-- -----
return {ranges=ranges, Nums=Nums, Syms=Syms}

