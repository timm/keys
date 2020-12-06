-- <img width=75 src="https://cdn0.iconfinder.com/data/icons/data-charts/110/TableDataGridThickLines-512.png">   <br>
-- <a href="http://github.com/timm/keys"><img src="https://github.blog/wp-content/uploads/2008/12/forkme_left_red_aa0000.png?resize=149%2C149" align=left></a>  
-- "Keys = cluster, discretize, elites, contrast"    
-- ![](https://img.shields.io/badge/platform-osx%20,%20linux-orange?style=flat-square)  
-- ![](https://img.shields.io/badge/language-lua,bash-blue?style=flat-square)  
-- ![](https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet?style=flat-square)  
-- ![](https://img.shields.io/badge/license-mit-green?style=flat-square)  
-- [home](http://menzies.us/keys) :: [lib](http://menzies.us/keys/lib.html) :: [tbl](http://menzies.us/keys/tbl.html)   
--------------------
local Of  = {
  synopois= "tables with rows, summarized in column headers",
  author  = "Tim Menzies, timm@ieee.org",
  license = "MIT",
  year    = 2020,
  seed    = 1,
  ch      = {skip="?", klass="!",sym="_", 
             num=":", more=">", less="<"},
  row     = {p=2,cols="ys"}}

-- ## Objects 
local Lib  = require "lib" 
local Col  = {}
local Num  = {ako="Num", pos=0,txt="",n=0, 
              mu=0, m2=0, sd=0, lo=math.huge, hi= -math.huge}
local Sym  = {ako="Sym", pos=0,txt="",n=0, 
              seen={}, most=0,mode=true}
local Skip = {ako="Skip"}
local Row  = {ako="Row",  cells={}, bins={}}
local Tbl  = {ako="Tbl",  rows={}, cols={},ys={},xs={}, dist={}}

---------------------
-- ## Shortcuts
local isa=Lib.isa
local function cell(x) return not(type(x)=="string" and x=="?") end

---------------------
-- ## Column summaries
-- Col
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

-- Skip
function Skip.new(n,s) return isa(Skip,{txt=s, pos=n}) end 
function Skip:add(x) return x end 

-- Sym
function Sym.new(n,s)  return isa(Sym, {txt=s, pos=n}) end

function Sym:add(x) 
  if cell(x) then
    self.n = self.n + 1
    self.seen[x] = (self.seen[x] or 0) + 1
    if self.seen[x] > self.most then 
      self.most, self.mode = self.seen[x], x end end
  return x end 

function Sym:dist(x,y) return x==y and 0 or 1 end

-- Num
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

---------------------
-- ## Row
function Row.new(row,tbl)
  local i = isa(Row)
  for _,col in pairs(tbl.cols) do 
    i.cells[col.pos] = col:add(row[col.pos])
    i.bins[col.pos] = i.cells[col.pos] end 
  return i end

function Row:dist(other,cols,      x,y,d1)
  local d,n,p = 0,1E-32,Of.row.p
  for _,col in pairs(cols) do
    x = self.cells[col.pos]
    y = other.cells[col.pos]
    d1= (not cell(x) and not cell(y)) and 1 or col:dist(x,y)
    d = d+d1^p 
    n = n+1 end
  return (d/n)^(1/p) end

---------------------
-- ## Tables 
function Tbl.new() return isa(Tbl) end

function Tbl:add(t)  
  if #self.cols==0 then 
    for j,x in pairs(t) do Col.factory(j,x,self) end 
  else
    self.rows[(#self.rows)+1] = Row.new(t,self) end end
      
-- Read from files
function Tbl.read(f,    t) 
  t=Tbl.new()
  for row in Lib.csv(f) do t:add(row) end
  return t end

------
-- ### Unsupervised descritization of nuermic columns
function Tbl:bins(samples,d,n,      some,lsd,bin,div)
  -- For one column: find a random `sample ` of the data
  local function some(pos, out)
    for _ in 1,samples do 
      local x = Lib.any(self.rows).cells[pos]
      if cell(row) then out[#out+1] = x end end  
    return out end
  -- For one list of sorted numbers, report its spread
  local function spread(t) 
    return (t[ math.floor(.9*#t) ] - t[ math.floor(.1*#t)])/2.54 end
  -- For one list of sorted numbers, divided into bins of size `n`
  local function div(t)
    local b4, lo, out, sd, n = 0, 1, {}, lsd(t), math.floor(n)
    for hi= n,#t-n do
      if hi - lo >= n then i      -- enough in his div
        if t[hi] ~= t[hi+1] then  -- there is a break here
          local now = t[math.floor(lo+(hi-lo)/2)]
          if now - b4 > d*sd then -- your different enough to last bin
            out[#out+1] = t[hi]
            b4,lo = now,hi end end end end
    return out end
  -- Report which bin has `x`
  local function bin(x,bins) 
    for j,b in pairs(bins) do if x<=b then return j end end
    return #bins+1 end 
  --- main
  samples = samples or 128
  d = d and d or .2
  n = n and n or .5
  n = (#self.rows)^n
  while(n < 4 and n < #t/2) do n = n*1.25 end
  for _,col in pairs(self.cols) do
    if col.ako == "Num" then
      local bins = div( Lib.sort(some(col.pos, {})))
      for _,r in pairs(self.rows) do
        r.bins[col.pos] = bin(r.cols[col.pos],bins) end end end end

 ------
-- And finally...
return {Tbl=Tbl,Row=Row,Sym=Sym,Num=Num}
