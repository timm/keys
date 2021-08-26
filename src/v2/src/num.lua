local Num={}
local obj =require"obj"
local some=require"some"
local col =require("col").weight
local _   =require("list"); local copy=_.copy

-- ## new(?at : int=0, ?name : str="")
function Num:new()
  name= name or ""
  return obj(self,"Num",{n=0, some=Some(), name=name or "",
                         at=at or 0, w=weight(name)}) end

-- ## add(x : num)
function Num:add1(x,    d)
  d       = x - self.mu
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x - self.mu)
  self.sd = (self.m2<0 or self.n<2) and 0 or (
            (self.m2/(self.n-1))^0.5)
  self.lo = math.min(x, self.lo)
  self.hi = math.max(x, self.hi)  end

-- ## delta(other : Num)
-- Return the difference in the means, mediated by the variances.
function Num:delta(other,    y,z,e)
  e, y, z = 1E-32, self, other
  return math.abs(y.mu - z.mu) / (
         (e + y.sd^2/y.n + z.sd^2/z.n)^.5) end

-- ## dist(x : num, y : num)
--  If any value missing, guess a value of the other that
-- maximizes the distance.
function Num:dist(x,y)
  if     x=="?" then y=self:norm(y); x = y>.5 and 0 or 1 
  elseif y=="?" then x=self:norm(x); y = x>.5 and 0 or 1 
  else               x,y = self:norm(x), self:norm(y) end
  return math.abs(x-y) end

-- ## merge(lst : num+)
-- Combine self with  a `lst` of other `Num`s.
function Num:merge(lst,      new)
  new = copy(self)
  for _,x in pairs(lst._all) do new:add(x) end
  return new end

-- ## mid()
-- Central tendency.
function Num:mid() return self.mu end 

-- ## norm(x : num)
-- Return `x` mapped into 0..1 for lo..hi.
function Num:norm(x,    a)
  if x =="?" then return x end
  return (x-self.lo) / (self.hi - self.lo + 1E-32) end

-- ## var()
-- Variance  of numerics  is the  standard deviation.
function Num:var() return self.sd end

-- ## same(other : Num, the:table)
-- Are two distributions the same?
function Num:same(other, the)
  return same(self.some:all(), other.some:all(), the) end

-- ## tile(width : int, ps : float+)
-- For all the `Nums` in `t`, print out normalized
-- in the `lo`..`hi` range of `self`.
function Num:tile(t,width,ps,    a,s,where)
  a = self.some:all()
  s = {}
  for i = 1, (width or 32) do s[i]=" " end
  where = function(n) return math.floor(width*self:norm(n)) end
  pos   = function(p) return a[1] + p*(a[#a] - a[1]) end
  for p=.1,.3,.01 do s[where(pos(p))] ="-" end 
  for p=.7,.9,.01 do s[where(pos(p))] ="-" end 
  s[where(self.some:mid())] = "|"
  return {rank= self.rank or 0,
          str = table.concat(s), 
          mid = per(self.some:all()),
          per = map(ps or {.25, .5, .75}, 
                    function (p) return per(self:all(),p) end)} end

-- --------
return Num
