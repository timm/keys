---
title: "SE for AI- less but better"
---


```{.lua .numberLines}

local function config() return {
  bins= {.5     ,'Bins are of size n**BINS'},
  cols= {'x'    ,'Columns to use for inference'},
  data= {'../data/auto2.csv' 
                ,'Where to read data'},
  eg=   {""     ,"'-x ls' lists all, '-x all' runs all"},
  far=  {.9     ,'Where to look for far things'},
  goaL= {'best' ,'Learning goals: best|rest|other'},
  iota= {.3     ,'Small = sd**iota'},
  k=    {2      ,'Bayes low class frequency hack'},
  loud= {false  ,'Set verbose'},
  m=    {1      ,'Bayes low range frequency hack'},
  p=    {2      ,'Distance calculation exponent'},
  some= {20     ,'Number of samples to find far things'},
  seed= {10013  ,'Seed for random numbers'},
  top=  {10     ,'Focus on this many'},
  un=   {false  ,'Run egs, no protection'} } end

-----------------------------------------------------------
local argparse = require("argparse")
local Obj,Eg       = {},{}     -- two of the usual objects
local Skip,Num,Sym = {},{},{}  -- columns
local Row,Rows     = {},{}     -- places to store data
local goalp,klassp,nump,weight,skipp,merged,adds -- column meta
local sorted,sort,map,copy,per -- lists
local fmt,color,dump,rump,pump -- strings
local round,Seed,rand,normal   -- maths
local csv                      -- files
local run,cli,main             -- mains, unit tests

--- columns, general---------------------------------------
function goalp(s)  return s:find("+") or s:find("-") or klassp(s) end
function klassp(s) return s:find("!") end
function nump(s)   return s:sub(1,1):match("[A-Z]") end
function weight(s) return s:find("-") and -1 or 1 end
function skipp(s)  return s:find("?") end

function merged(i,j,         k)
  k= i:merge(j)
  if k:var() < (i.n*i:var() + j.n*j:var()) / (i.n + j.n) then 
    return k end end

function adds(a,i) 
  i = i or (type(a[1])=="number" and Num or Sym):new()
  for _,x in pairs(a) do i:add(x) end 
  return i end

--- Skip ---------------------------------------------------
function Skip:new(at,s) 
  return Obj.new(self,"Skip",{
    n=0, s=s or "", at=at or 0}) end
function Skip: add(x) return  x end

--- Sym ---------------------------------------------------
function Sym:new(at,s)  
  return Obj.new(self,"Sym",{
    n=0, s=s or "", at=at or 0,
    has={},mode=0,most=0}) end

function Sym:add(x)
  if x ~= "?" then
    self.n = self.n+ 1
    self.has[x] = 1+ (self.has[x] or 0)
    if self.has[x] > self.most  then
      self.most, self.mode = self.has[x], x end  end
  return  x end

function Sym:merge(other)
  new=copy(self)
  for k,v in pairs(other.has) do 
     new.n = new.n + v
     new.has[k] = v + (new.has[k] or 0) end
  for k,v in pairs(new.has) do
    if v > new.most then new.mode, new.most = k,v end end 
  return new end

function Sym:var(x,     e,p)
  e= 0
  p= function(n) return n/self.n end
  for _,v in pairs(self.has) do e=e - p(v)*math.log(p(v),2) end 
  return e end

function Sym:dist(x,y) return x==y and 0 or 1 end

--- Num ---------------------------------------------------
function Num:new(at,s,      w)
  s= s or ""
  return Obj.new(self,"Num",{
    n=0, s=s, at=at or 0,
    _all={}, ok=false, w=weight(s   )}) end

function Num:mid() return per(self:all(),.5) end
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

function Num:merge(other,      new)
  new = copy(self)
  for _,v in other._all do new:add(x) end
  return new end

function Num:norm(x)
  if x =="?" then return x end
  a = self:all()
  return (x-a[1]) / (a[#a] - a[1] + 1E-32) end

function Num:dist(x,y)
  if     x=="?" then y=self:norm(y); x = y>.5 and 0 or 1 
  elseif y=="?" then x=self:norm(x); y = x>.5 and 0 or 1 
  else               x,y = self:norm(x), self:norm(y) end
  return math.abs(x-y) end

--- row and rows  --------------------------------------------------
```

What kind of column should be created from `s`?

```{.lua .numberLines}

function Row:new(a,rows)
  return Obj.new(self,"Row",{cells=a, rows=rows}) end

function Row:dist(other,the,       a,b,d,n)
  d,n=0,1E-32
  for _,col in pairs(self.rows.cols[the.cols]) do
    n   = n + 1
    a,b = self.cells[col.at], other.cells[col.at]
    if    a=="?" and b=="?" 
    then  d = d+1
    else  print(col:dist(a,b))
          d = d + col:dist(a.b)^the.p end end
  return  (d/n)^(1/the.p) end

function Rows:new(inits,     x)
  x= Obj.new(self,"Rows",{
      rows={},
      cols={all={},names={},x={},y={}}})
  for _,row in pairs(inits or {}) do x:add(row) end  
  return x end

function Rows:read(f) 
  for row in csv(f) do self:add(row) end 
  return self end

function Rows:add(a)
   a= a._name=="Rows"and a.cells or a
   if #(self.cols.names) > 0 then self:data(a) else self:header(a) end
end

function Rows:data(a)
  for _,col in pairs(self.cols.all) do a[col.at]=col:add(a[col.at]) end
  self.rows[ 1 + #self.rows] = Row:new(a,self) end

function Rows:header(a,   what,new,tmp)
  self.cols.names=a
  for at,txt in pairs(a)  do
    what = skipp(txt) and Skip or (nump(txt) and Num or Sym)
    new  = what:new(at,txt) 
    self.cols.all[1+#self.cols.all] = new
    if not skipp(txt) then
      tmp= self.cols[goalp(txt) and  "y" or "x"]
      tmp[1+#tmp] = new
      if klassp(txt) then i.cols.klass = new end end end end

--- lists --------------------------------------------------
function sorted(t,         i,keys)
  i,keys = 0,{}
  for k in pairs(t) do keys[#keys+1] = k end
  table.sort(keys)
  return function ()
    if i < #keys then
      i=i+1; return keys[i], t[keys[i]] end end end

function sort(a,f)
  table.sort(a, f or function(x,y) return x<y end)
  return a end

function map(a,f,     b)
  b, f = {}, f or function(z) return z end
  for i,v in pairs(a or {}) do b[i] = f(v) end 
  return b end 

function copy(obj, seen,      s, res)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  s = seen or {}
  res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res end

function per(a,p) 
  return a[math.max(1,math.floor(#a*(p or .5)))] end

--- strings -----------------------------------------------
function fmt(s,...) return io.write(s:format(...)) end 

function color(s,...)
  local x={red=31, green=32, yellow=33, purple=34}
  print('\27[1m\27['..x[s]..'m'..string.format(...)..'\27[0m') end

function dump(o,     sep,s)
  sep, s = "", (o._name or "") .."{"
  if (#o > 0) then
    for i=1,#o do
      s=s .. sep .. tostring(o[i])
      sep=", " end 
  else
    for k,v in sorted(o) do 
      if k:sub(1,1) ~= "_" then
        s=s .. sep .. tostring(k).."="..tostring(v)
        sep=", " end end end
  return s.."}" end

function rump(t,pre,    indent,fmt)
  pre, indent = pre or "", indent or 0
  if indent < 10 then
    for k, v in pairs(t or {}) do
      if not (type(k)=='string' and k:match("^_")) then
        fmt= pre..string.rep("|  ",indent)..tostring(k)..": "
        if type(v) == "table" then
          print(fmt)
          rump(v, pre, indent+1)
        else
          print(fmt .. tostring(v)) end end end end end

function pump(o) print(dump(o)) end

--- maths -------------------------------------------------
function round(num, decimals,      mult)
  mult = 10^(decimals or 0)
  return math.floor(num * mult + 0.5) / mult end

function normal(mu,sd)
  local sqrt, log, cos, pi = math.sqrt, math.log, math.cos, math.pi
  return mu+sd*sqrt(-2*log(rand()))*cos(2*pi*rand()) end

Seed = 10013
function rand(lo,hi,     mult,mod)
  lo,hi = lo or 0, hi or 1
  mult, mod = 16807, 2147483647
  Seed = (mult * Seed) % mod 
  return lo + (hi-lo) * Seed / mod end 

--- file --------------------------------------------------
function csv(file,       split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      tmp = tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      t={}; for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if #t > 0 then
        for j,x in pairs(t) do t[j]=tonumber(x) or x end
        return t end
    else
      io.close(stream) end end end

function Obj.new(self, name, new)
  new = new or {}
  setmetatable(new, self)
  self.__tostring = dump 
  self.__index    = self
  self._name      = name
  return new end

function cli(what,about,t,       arg,b4)
  arg = argparse(what, about)
  for flag,v in sorted(t) do
    flag = "--"..flag
    b4 =" (default: "..tostring(v[1])..")"
    if     v[1]==false
    then   arg:flag(flag, v[2],  v[1])
    elseif type(v[1])=="number"
    then   arg:option(flag, v[2]..b4, v[1],tonumber)
    else   arg:option(flag, v[2]    , v[1]) end end 
  return arg:parse() end

--- main -------------------------------------------------
function run(txt,fails,the,      it)
  the  = copy(the)
  Seed = the.seed
  it   = Eg[txt]
  if     the.un==true 
  then   print("unsafe:"); it.fun(the)
  elseif pcall(function () it.fun(the); end)
  then   color("green","✔ % -15s  %s",txt,it.txt); fails=fails+0
  else   color("red",  "✘ %-15s  %s" ,txt,it.txt); fails=fails+1 end 
  return fails end

function main(the,      fails)
  fails= 0
  if     the.eg=="all"
  then   for txt,meta in sorted(Eg) do
           fails=run(txt, fails, the) end 
  elseif the.eg=="ls" 
  then   print("\neegs:")
         for x,y in sorted(Eg) do fmt("  %-15s  %s\n",x,y.txt) end 
  elseif the.eg and Eg[the.eg] 
  then   fails = run(the.eg, fails, the) end
  for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
  os.exit(fails) end

--- unit tests ---------------------------------------------
Eg.sorted= {
  txt = "sorting items",
  fun = function(_) 
         for x,y in sorted{mm=10,zz=2,cc=3,aa=1} do 
           return assert(x=="aa" and y==1)  end end}

Eg.map= {
  txt="meta map functions",
  fun=function(_,  f) 
        f= function(z) return z*2 end
        assert(40 ==  map({10,20,30},f)[2]) end}

Eg.copy= {
  txt="deep copy",
  fun=function(_,        a,b) 
               a={1,{2,{3,{4},5},6},7}
               b=copy(a)
               a[2][2][2][1]=10 
        assert(b[2][2][2][1]==4)   end}

Eg.num={
  txt="number",
  fun=function(_,     n)
        n=Num:new()
        for i=1,10000 do n:add(round(rand(),2)) end
        n:var() end }
        
Eg.rand={
  txt="random numbers",
  fun=function(_,      a)
        a={}
        for i=1,10 do a[1+#a] = round(rand(),2) end 
        pump(sort(a)) end}
        
Eg.meta={
  txt="column header types",
  fun=function(_)
        assert(      goalp( "word+"))
        assert(nil== goalp( "word"))
        assert(      klassp("word!"))
        assert(nil== klassp("word"))
        assert(      nump(  "Word"))
        assert(nil== nump(  "word"))
        assert(-1 == weight("word-"))
        assert( 1 == weight("word+"))
        assert(      skipp( "word?"))
        assert(nil== skipp( "word")) end}
                
Eg.num={
  txt="standard deviation",
  fun=function(_,    mu,sd,eps, n,num)
        num=Num:new()
        n,mu, sd, eps = 1000, 10, 1, .05
        for i=1,n do num:add(normal(mu,sd)) end
        assert(math.abs(sd - num:var()) < eps)
        assert(math.abs(mu - num:mid()) < eps) end }

Eg.sym={
  txt="entropy",
  fun=function(_,        e0,e1,eps)
        e0, eps = 1.3787834, 0.0001
        assert(0==adds({"a","a","a","a"}):var())
        e1 =adds({"a","a","a","a","b","b","c"}):var()
        assert(math.abs(e1 - e0) < eps) end }

Eg.csv={
  txt="loading csv",
  fun=function(the,       n)
        for row in csv(the.data) do 
          n  = n or #row
          assert(n==#row)  end end}

Eg.rows={
  txt="loading rows",
  fun=function(the,       t)
        t = Rows:new():read(the.data)
        rump(t.cols.all[2])
      end}

Eg.dist={
  txt="checking distances",
  fun=function(the,       t)
        t = Rows:new():read(the.data)
        for _,row1 in pairs(t.rows) do
          for _,row2 in pairs(t.rows) do
            row1:dist(row2,the) end end
      end}
-----------------------------------------------------------
main( cli("./keys", about, config()) )

```
