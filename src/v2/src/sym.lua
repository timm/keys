-- # class Sym
-- |Does  |: 1     |: incrementally maintain symbol counts|
-- |----  |---     |------------------------------------------|
-- |      |: 2     |: knows the most common symbol   |
-- |      |: 3     |: support inference (distance, likelihood)|
-- |Has   |: at    |: column index                |
-- |      |: name  |: column name                  |
-- |      |: n     |: counter of things seen so far |
-- |      |: has   |: symbol counts.                |
-- |      |: mode  |: most common symbol.           |
-- |      |: _most |: frequency of most seen symbol |
local Sym = {}
local obj = require"obj"

-- **new(?at : int=0, ?name : string="") : Sym**   
function Sym:new(at, name)  
  return obj(self,"Sym",{
    n=0, name=name or "", at=at or 0,
    has={},mode=0,_most=0}) end

-- **add(x : atom)**  
-- Update.
function Sym:add(x)
  if x ~= "?" then
    self.n = self.n+ 1
    self.has[x] = 1+ (self.has[x] or 0)
    if self.has[x] > self._most  then
      self._most, self.mode = self.has[x], x end  end
  return  x end

-- **dist(x : atom, y : atom)**   
-- Return the gap between symbols `x` and `y`.
function Sym:dist(x,y) 
  return x==y and 0 or 1 end

-- **merge(other : Sym) : Sym**  
-- Return a  new `Sym` after combining `self` with `other`.
function Sym:merge(other)
  new=copy(self)
  for k,v in pairs(other.has) do 
     new.n = new.n + v
     new.has[k] = v + (new.has[k] or 0) end
  for k,v in pairs(new.has) do
    if v > new._most then new.mode, new._most = k,v end end 
  return new end

-- **var()**    
-- Return the work require to recreate a signal.
function Sym:var(     e,p,w)
  e= 0
  for _,v in pairs(self.has) do 
     p= v/self.n      -- probability of wanting is
     w= math.log(p,2) -- work required to fund it
     e= e - p*w end
  return e end

return Sym
