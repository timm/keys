-- Symbolic columns keep symbol counts (in `has`) and know
-- the `mode` (most common) value.
local Sym = {}
local obj = require"obj"

-- **new(at : int=0, name : string="") : Sym**   
-- - n   : int = 0. Counter of things seen so far.
-- - ?at : int = 0. Column number.
-- - ?name : str = "". Column name.
-- - has : table. Symbol counts.
-- - mode : atom. Most common symbol.
-- - most : int. Frequency of most common symbol.
function Sym:new(at, name)  
  return obj(self,"Sym",{
    n=0, name=name or "", at=at or 0,
    has={},mode=0,most=0}) end

-- **add(x : atom)**  
-- Update.
function Sym:add(x)
  if x ~= "?" then
    self.n = self.n+ 1
    self.has[x] = 1+ (self.has[x] or 0)
    if self.has[x] > self.most  then
      self.most, self.mode = self.has[x], x end  end
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
    if v > new.most then new.mode, new.most = k,v end end 
  return new end

-- **var()**    
-- Return the work require to recreate a signal.
function Sym:var(     e,p)
  e= 0
  p= function(n) return n/self.n end
  for _,v in pairs(self.has) do e=e - p(v)*math.log(p(v),2) end 
  return e end

return Sym
