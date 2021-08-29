--vim: filetype=lua ts=2 sw=2 sts=2 et :

-- # Sym
local Sym={}
-- Symbolic columns keep symbol counts (in `has`) and know
-- the `mode` (most common) value.
-- ## method new(at:_int_=0,  s:_string_="")
-- Create
function Sym:new(at,s)  
  return Obj.new(self,"Sym",{
    n=0, s=s or "", at=at or 0,
    has={},mode=0,most=0}) end

-- ## method add(x:_atom_)
-- Update.
function Sym:add(x)
  if x ~= "?" then
    self.n = self.n+ 1
    self.has[x] = 1+ (self.has[x] or 0)
    if self.has[x] > self.most  then
      self.most, self.mode = self.has[x], x end  end
  return  x end

-- ## method dist(x:_atom_, y:_atom_))
-- Return the gap between symbols `x` and `y`.
function Sym:dist(x,y) return x==y and 0 or 1 end

-- ## method merge(other:_Sym_)
-- Return a  new `Sym` after combining `self` with `other`.
function Sym:merge(other)
  new=copy(self)
  for k,v in pairs(other.has) do 
     new.n = new.n + v
     new.has[k] = v + (new.has[k] or 0) end
  for k,v in pairs(new.has) do
    if v > new.most then new.mode, new.most = k,v end end 
  return new end

-- ## method var()
-- Return entropy.
function Sym:var(     e,p)
  e= 0
  p= function(n) return n/self.n end
  for _,v in pairs(self.has) do e=e - p(v)*math.log(p(v),2) end 
  return e end

return Sym
