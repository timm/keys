--vim: filetype=lua ts=2 sw=2 sts=2 et :

-- # Num
local Num={}
function Num:new(at,s,      w)
  s= s or ""
  return Obj.new(self,"Num",{
    n=0, s=s, at=at or 0, 
    _all={}, ok=false, w=weight(s   )}) end

function Num:mid() 
  return per(self:all(),.5) end

function Num:mu(    sum) 
  sum=0
  for _,x in pairs(self._all) do sum = sum+x end
  return sum/#self._all end

-- variance  of numerics  is the  standard deviation.
function Num:var(   a) 
   a=self:all(); return (per(a,.9)-per(a,.1))/2.54 end

function Num:all()
  if     not self.ok 
  then   self.ok=true; self._all = sort(self._all) end
  return self._all end

function Num:add(x)
  if  x ~= "?" then
    self.n = self.n + 1
    self._all[ 1 + #self._all] = x
    self.ok= false end
  return x end 

function Num:norm(x,    a)
  if x =="?" then return x end
  a = self:all()
  return (x-a[1]) / (a[#a] - a[1] + 1E-32) end

--  If any value missing, guess a value of the other that
-- maximizes the distance.
function Num:dist(x,y)
  if     x=="?" then y=self:norm(y); x = y>.5 and 0 or 1 
  elseif y=="?" then x=self:norm(x); y = x>.5 and 0 or 1 
  else               x,y = self:norm(x), self:norm(y) end
  return math.abs(x-y) end
 
function Num:delta(other,    y,z,e)
  y, z, e = self, other, 0
  return math.abs(y:mu() - z:mu()) / (
         (e + y:var()^2/y.n + z:var()^2/z.n)^.5) end

-- are two distributions the same?
function Num:same(other, the)
  return same(self:all(), other:all(), the) end

function Num:tile(t,width,ps,    s,where)
  a= self:all()
  s = {}
  for i = 1, (width or 32) do s[i]=" " end
  where = function(n) return math.floor(width*self:norm(n)) end
  pos   = function(p) return a[1] + p*(a[#a] - a[1]) end
  for p=.1,.3,.01 do s[where(pos(p))] ="-" end 
  for p=.7,.9,.01 do s[where(pos(p))] ="-" end 
  s[where(self:mid())] = "|"
  return {rank= self.rank or 0,
          str = table.concat(s), 
          mid = per(self:all()),
          per = map(ps or {.25, .5, .75}, 
                    function (p) return per(self:all(),p) end)} end

function Num:merge(other,      new)
  new = copy(self)
  for _,x in pairs(other._all) do new:add(x) end
  return new end

return Num
