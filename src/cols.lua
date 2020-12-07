-- <img width=75 src="https://www.flaticon.com/svg/static/icons/svg/2286/2286294.svg"> <hr>
-- <a href="http://github.com/timm/keys"><img src="https://github.blog/wp-content/uploads/2008/12/forkme_left_red_aa0000.png?resize=149%2C149" align=left></a>  
-- "Keys = cluster, discretize, elites, contrast"    
-- [![DOI](https://zenodo.org/badge/318809834.svg)](https://zenodo.org/badge/latestdoi/318809834)  
-- ![](https://img.shields.io/badge/platform-osx%20,%20linux-orange)    
-- ![](https://img.shields.io/badge/language-lua,bash-blue)  
-- ![](https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet)  
-- [![Build Status](https://travis-ci.com/timm/keys.svg?branch=main)](https://travis-ci.com/timm/keys)   
-- ![](https://img.shields.io/badge/license-mit-lightgrey)  
-- [home](http://menzies.us/keys)         :: [lib](http://menzies.us/keys/lib.html) ::
-- [cols](http://menzies.us/keys/cols.html) :: [tbl](http://menzies.us/keys/tbl.html)   
--------------------
local Of  = {
  synopois= "`Col`s summarize  columns of data",
  author  = "Tim Menzies, timm@ieee.org",
  license = "MIT",
  year    = 2020,
  seed    = 1,
  ch      = {skip="?", klass="!",sym="_", 
             num=":", more=">", less="<"},
  some    = {n=.5, d=.2}}

-- ## Objects
local Lib  = require "lib" 
local Col  = {}
local Num  = {ako="Num", pos=0,txt="",n=0, 
              mu=0, m2=0, sd=0, lo=math.huge, hi= -math.huge}
local Sym  = {ako="Sym", pos=0,txt="",n=0, 
              seen={}, most=0,mode=true}
local Some = {ako="Some", pos=0,txt="",n=0, 
              has={}, ok=false, max=256, bins={}}
local Skip = {ako="Skip"}

---------------------
-- ## Shortcuts
local isa=Lib.isa
local function cell(x) return not(type(x)=="string" and x=="?") end

---------------------
-- ## Column summaries
-- ### Col
function Col.factory(j,s,t) 
  local tmp,aka = Sym, t.xs
  if s:find(Of.ch.num)  then tmp     = Num        end
  if s:find(Of.ch.less) then tmp,aka = Num, t.ys  end
  if s:find(Of.ch.more) then tmp,aka = Num, t.ys  end
  if s:find(Of.ch.sym)  then tmp     = Sym        end
  if s:find(Of.ch.skip) then tmp,aka = Skip,{}    end
  local x = tmp.new(j,s)
  if s:find(Of.ch.klass) then t.class,aka = x,t.ys end 
  t.cols[j] = x
  aka[j]= x end

-- ### Num
function Num.new(n,s) 
  local  x=isa(Num, {txt=s, pos=n})
  x.w = x.txt:find(Of.ch.less) and -1 or 1
  return x end

function Num:add(x) 
  if cell(x) then
    self.n = self.n + 1
    local d = x - self.mu
    self.mu = self.mu + d / self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.m2<0 and 0 or (
              self.n<2  and 0 or (
              (self.m2/(self.n -1))^0.5))
    self.lo = math.min(self.lo,x)
    self.hi = math.max(self.hi,x) end
  return x end

function Num:norm(x) return (x - self.lo) / (self.hi - self.lo + 1E-32) end

function Num:dist(x,y)
  if      not cell(x) then y   = self:norm(y); x=y>0.5 and 0 or 1 
  else if not cell(y) then y   = self:norm(y); y=x>0.5 and 0 or 1 
  else                     x,y = self:norm(x), self:norm(y) end end
  return math.abs(x-y) end 

-- ### Skip
function Skip.new(n,s) return isa(Skip,{txt=s, pos=n}) end 
function Skip:add(x) return x end 

-- ### Some
-- A reservoir sampler. 
function Some.new(n,s) return isa(Some,{txt=s,pos=n}) end

-- While there is space, add anything.
-- Once we are full, new additions delete some older item
-- (selected at random).
function Some:add(x,   j)
  local r = math.random
  if cell(x) then
    self.n = self.n + 1
    if #self.has < self.max then j = #self.has+1   
    elseif r() < self.max/self.n then j = r(#self.has)  
    end 
    if j then self.has[j]=x; self.ok=false end end
  return x end 

function Some:all() 
  if not self.ok then self.ok = true; table.sort(self.has) end
  return self.has end

function Some:sd(    t)
  t = self:all()
  return (t[.9*#t//1] - t[.1*#t//1]) / 2.54 end

function Some:bin(x,bins)
  if not cell(x) then return x end
  local say=function (n) return string.format("%s/%s",n,#bins+1) end
  for j,b in pairs(bins) do if x<=b then return say(j) end end
  return say(#bins+1)  end 

function Some:bins(i)
  i = i or {}
  local d = i.d or Of.some.d -- .2
  local n = i.n or Of.some.n -- .5 
  local epsilon = i.epsilon or d*self:sd()
  n = (#self.has)^n
  while(n < 4 and n < #self.has/2) do n = n*1.1 end
  local b4, lo, out,  n = 0, 1, {},  n//1
  for hi = n, #self.has - n do
    if hi - lo >= n then                      -- now enough in the div
      if self.has[hi] ~= self.has[hi+1] then  -- there is a break here
        local now = self.has[lo+(hi-lo)//2]
        if now - b4 > epsilon then -- your different enough to last bin
          out[#out+1] = self.has[hi]
          b4,lo = now,hi end end end end
  return out end

-- ### Sym
function Sym.new(n,s)  return isa(Sym, {txt=s, pos=n}) end

function Sym:add(x) 
  if cell(x) then
    self.n = self.n + 1
    self.seen[x] = (self.seen[x] or 0) + 1
    if self.seen[x] > self.most then 
      self.most, self.mode = self.seen[x], x end end
  return x end 

function Sym:dist(x,y) return x==y and 0 or 1 end

------
-- And finally...
return {Col=Col, Sym=Sym,Some=Some,Num=Num}
