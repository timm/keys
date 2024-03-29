-- # class Sym
-- |**Does** | 1     |: incrementally maintain symbol counts |
-- |----     |------:|---------------------------------------|
-- |         | 2     |: knows the most common symbol|
-- |         | 3     |: support inference (distance, likelihood)|
-- |**Has**  | at    |: column index|
-- |         | name  |: column name|
-- |         | n     |: counter of things seen so far|
-- |         | has   |: symbol counts|
-- |         | mode  |: most common symbol|
-- |         | _most |: frequency of most seen symbol|

local Sym = {}
local obj = require"obj"
local lst = require"list"

-- ## Creation
-- **new(?at : int=0, ?name : str="") : Num**   
-- **new(?at : int=0, ?name : string="") : Sym**   
function Sym:new(at, name)  
  return obj(self,"Sym",{
    n=0, name=name or "", at=at or 0,
    has={},mode=0,_most=0}) end

-- -----
-- ## Update
-- **add(x : atom)**   
-- Update.
function Sym:add(x)
  if x ~= "?" then
    self.n = self.n+ 1
    self.has[x] = 1+ (self.has[x] or 0)
    if self.has[x] > self._most  then
      self._most, self.mode = self.has[x], x end end end

-- ----------
-- ## Distance
-- **dist(x : atom, y : atom)**   
-- Return the gap between symbols `x` and `y`.
-- Implements Aha's instance-based distance algorithm (for symbolic attributes);
-- see [section 2.4](https://link.springer.com/content/pdf/10.1007/BF00153759.pdf).
function Sym:dist(x,y) 
  return x==y and 0 or 1 end

-- ------
-- ## Copy
-- **merge(other : Sym) : Sym**  
-- Return a  new `Sym` after combining `self` with `other`.
function Sym:merge(other)
  new = lst.copy(self)
  for k,v in pairs(other.has) do 
     new.n = new.n + v
     new.has[k] = v + (new.has[k] or 0) end
  for k,v in pairs(new.has) do
    if v > new._most then new.mode, new._most = k,v end end 
  return new end

-- -----
-- ## Query
-- **mid() : any**    
-- Central tendency.
function Sym:mid() 
  return self.mode end 

-- **var()**    
-- Return the work require to recreate a signal.
function Sym:var(     e,p,w)
  e= 0
  for _,v in pairs(self.has) do 
     p= v/self.n      -- probability of wanting it
     w= math.log(p,2) -- how hard to find it (via binary chop)
     e= e - p*w end
  return e end

return Sym
