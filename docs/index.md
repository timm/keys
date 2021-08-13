---
title: keys
layout: page
---


      ,-_|\   keys
     /     \  (c) Tim Menzies, 2021, unlicense.org
     \_,-._*  Cluster, then report just the 
          v   deltas between nearby clusters.  


```lua
local argparse = require("argparse")
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
```

---------------------------------------------
## About
All the `options` are available as command line flags, e.g.

      ./keys --bins 10 --loud

Boolean options have no  arguments (e.g. `loud`). Mentioning
booleans    on the command line will set that option to `true`.
 
The `--eg X` runs the unit tests. Use `--eg ls`  to list those
tests. ``--eg all``  will run all tests. 

If a test  crashes,
and  you  want to see  the  stacktrace, run the  test again in 
`un`safe mode; e.g

    ./bins --un --eg abcd

### The `the` variable.
The config  options  are never set  globally. Rather, they
are carried  around in  a local variable  called `the`. In
this way, different parts  of the code could use different  config
settings.

```lua
local about={
   synopsis = [[
 ,-_|\   keys
/     \  (c) Tim Menzies, 2021, unlicense.org
\_,-._*  Cluster, then report just the 
     v   deltas between nearby clusters.  ]],
   usage    = "./keys",
   author   = "Tim Menzies",
   copyright= "(c) Tim Menzies, 2021, unlicense.org",
   options  = {
        bins= {.5     ,'Bins are of size n**BINS'},
        cols= {'x'    ,'Columns to use for inference'},
        data= {'../data/auto2.csv' 
                      ,'Where to read data'},
        eg=   {""     ,"'-x ls' lists all, '-x all' runs all"},
        far=  {.9     ,'Where to look for far things'},
        goaL= {'best' ,'Learning goals: best|rest|other'},
        iota= {.3     ,'Small = sd**iota'},
        k=    {2      ,'Bayes low class frequency hack'},
        knn=  {2      ,'Number of neighbors for knn'},
        kadd= {"mode", "combination rule of knn"},
        loud= {false  ,'Set verbose'},
        m=    {1      ,'Bayes low range frequency hack'},
        p=    {2      ,'Distance calculation exponent'},
        some= {20     ,'Number of samples to find far things'},
        seed= {10013  ,'Seed for random numbers'},
        top=  {10     ,'Focus on this many'},
        un=   {false  ,'Run egs, no protection (unsafe mode)'},
        wait= {10     ,'Pause before thinking'}}}
```

-------------------------------------------------------
##  Classes
`Obj`  is  the class creation factor. `Eg` stores the
unit and  system tests.

```lua
local Obj,Eg       = {},{}     
```

Columns. `Skip` is for columns we want to ignoe
the  others are for columns of  `Num`bers  or  `Sym`bols.

```lua
local Skip,Num,Sym = {},{},{}  
```

`Rows` is a  container  classes that holds
`Row`s and column summaries.

```lua
local Row,Rows     = {},{}    
```

Reporting.

```lua
local Err,Abcd     = {},{}   
```

## Functions
For columns.

```lua
local goalp,klassp,nump,weight,skipp,merged,adds 
```

Meta functions

```lua
local fun,locals            
```

 For lists.

```lua
local eq,sorted,sort,map,copy,per,shuffle,inc,max 
```

 For strings.

```lua
local fmt,color,dump,rump,pump,linem,printm   
```

For maths.

```lua
local rnd,Seed,rand,randi,normal   
```

 For  files.

```lua
local csv                  
```

 Code  called at start-up.

```lua
local run,main        
```


-----------------------------------------------------------
## columns, general

This code reads tables of data where line1 shows the name
for each column. For example:

    name?, Age, Shoesize, Job,  Salary+ YearsOnJob-
    tim,   21,  10,       prof, 100,     100
    jane,  60,  10,       hod,  1000,    10
    ...    ..   ..        ..    ..       ..

Note that the row1 names have magic symbols.
Numerics start with uppercase. Goals to be minimize or
maximized end with `-` and `+` (respectively). Columns
to be ignored contain `?`. Columns usually have a `weight`
of "1" unless we are minimizing them in which case that is "-1".


```lua
function klassp(s) return s:find("!") end
function goalp(s)  return s:find("+") or s:find("-") or klassp(s) end
function nump(s)   return s:sub(1,1):match("[A-Z]") end
function weight(s) return s:find("-") and -1 or 1 end
function skipp(s)  return s:find("?") end
```


Each column (except for `Skip`) needs its own version of the
following:

- `:add()`  : add `x` to the column;
- `:dist()` : returns probability that `x` belongs to the
- `:like()` : returns distance between two values in this column.
- `:merge()` : combine two columns
- `:mid()` : return the central tendency of a  column
- `:new()`  : returns a new column
- `:var()` : reports how values can vary around the `mid`.

```lua

```

The following functions work for all columns.
 `adds()` lets you create one or update a `col`umn with a list of
column `a`  (and if creating, then it guesses column type from the
first entry).

```lua
function adds(a,col) 
  col = col or (type(a[1])=="number" and Num or Sym):new()
  for _,x in pairs(a) do col:add(x) end 
  return col end
```


Finally, `merged()` checks if life is simpler if we combine two columns.

```lua
function merged(i,j,         k)
  k= i:merge(j)
  if k:var() < (i.n*i:var() + j.n*j:var()) / (i.n + j.n) then 
    return k end end
```


----------------------------------------------------------
## Specific Columns
### Skip 
Columns for data that we just want to ignore.

```lua

function Skip:new(at,s) 
  return Obj.new(self,"Skip",{
    n=0, s=s or "", at=at or 0}) end
```



```lua
function Skip: add(x) return  x end
```



```lua
function Skip: like(x,_) return 1 end
```


----------------------------------------------------------
### Sym
Symbolic columns keep symbol counts (in `has`) and know
the `mode` (most common) value.

```lua

function Sym:new(at,s)  
  return Obj.new(self,"Sym",{
    n=0, s=s or "", at=at or 0,
    has={},mode=0,most=0}) end
```



```lua
function Sym:add(x)
  if x ~= "?" then
    self.n = self.n+ 1
    self.has[x] = 1+ (self.has[x] or 0)
    if self.has[x] > self.most  then
      self.most, self.mode = self.has[x], x end  end
  return  x end
```



```lua
function Sym:merge(other)
  new=copy(self)
  for k,v in pairs(other.has) do 
     new.n = new.n + v
     new.has[k] = v + (new.has[k] or 0) end
  for k,v in pairs(new.has) do
    if v > new.most then new.mode, new.most = k,v end end 
  return new end
```


Variance of symbols is called entropy.

```lua
function Sym:var(x,     e,p)
  e= 0
  p= function(n) return n/self.n end
  for _,v in pairs(self.has) do e=e - p(v)*math.log(p(v),2) end 
  return e end
```



```lua
function Sym:dist(x,y) return x==y and 0 or 1 end
```


----------------------------------------------------------
### Num

```lua

function Num:new(at,s,      w)
  s= s or ""
  return Obj.new(self,"Num",{
    n=0, s=s, at=at or 0,
    _all={}, ok=false, w=weight(s   )}) end
```



```lua
function Num:mid() 
  return per(self:all(),.5) end
```


variance  of numerics  is the  standard deviation.

```lua
function Num:var(   a) 
   a=self:all(); return (per(a,.9)-per(a,.1))/2.54 end
```



```lua
function Num:all()
  if     not self.ok 
  then   self.ok=true; self._all = sort(self._all) end
  return self._all end
```



```lua
function Num:add(x)
  if  x ~= "?" then
    self.n = self.n + 1
    self._all[ 1 + #self._all] = x
    self.ok= false end
  return x end 
```



```lua
function Num:merge(other,      new)
  new = copy(self)
  for _,v in other._all do new:add(x) end
  return new end
```



```lua
function Num:norm(x,    a)
  if x =="?" then return x end
  a = self:all()
  return (x-a[1]) / (a[#a] - a[1] + 1E-32) end
```


 If any value missing, guess a value of the other that
maximizes the distance.

```lua
function Num:dist(x,y)
  if     x=="?" then y=self:norm(y); x = y>.5 and 0 or 1 
  elseif y=="?" then x=self:norm(x); y = x>.5 and 0 or 1 
  else               x,y = self:norm(x), self:norm(y) end
  return math.abs(x-y) end
```


------------------------------------------------
## Row
Store one example.

```lua
function Row:new(a,rows)
  return Obj.new(self,"Row",{cells=a, _rows=rows}) end
```



```lua
function Row:klass() 
  return self.cells[self._rows.cols.klass.at] end
```



```lua
function Row:dist(other,the,       a,b,d,n)
  d,n=0,1E-32
  for _,col in pairs(self._rows.cols[the.cols]) do
    n   = n + 1
    a,b = self.cells[col.at], other.cells[col.at]
    if    a=="?" and b=="?" 
    then  d = d + 1
    else  d = d + col:dist(a,b)^the.p end end
  return  (d/n)^(1/the.p) end
```


Store many  examples, summarized in columns.

```lua
function Rows:new(inits,     x)
  x= Obj.new(self,"Rows",{
      rows={}, keep=true,
      cols={all={},names={},x={},y={}}})
  for _,row in pairs(inits or {}) do x:add(row) end  
  return x end
```


clone a copy 

```lua
function  Rows:clone(inits,    t)
  t = Rows:new({self.cols.names})
  for _,x in pairs(inits or {}) do 
    t:add(x) end
  return t end
```


Read from a file

```lua
function Rows:read(f) 
  for row in csv(f) do self:add(row) end 
  return self end
```


If this is row1, create the header. Else, add new data.

```lua
function Rows:add(a)
   a = (a._name and a._name=="Row" and a.cells) or a
   if   #(self.cols.names) > 0 
   then return self:data(a) 
   else return self:header(a) end end
```


Update the column summaries. Maybe  keep the new row.

```lua
function Rows:data(a,    row)
  for _,col in pairs(self.cols.all) do 
     a[col.at]=col:add(a[col.at]) end
  if self.keep then
    row = Row:new(a,self) 
    self.rows[ 1 + #self.rows] = Row:new(a,self) end 
  return row end
```


Read the magic symbols, make the appropriate columns,
store them in the right  places.

```lua
function Rows:header(a,   what,new,tmp)
  self.cols.names=a
  for at,txt in pairs(a)  do
    what = skipp(txt) and Skip or (nump(txt) and Num or Sym)
    new  = what:new(at,txt) 
    self.cols.all[1+#self.cols.all] = new
    if not skipp(txt) then
      tmp= self.cols[goalp(txt) and  "y" or "x"]
      tmp[1+#tmp] = new
      if klassp(txt) then self.cols.klass = new end end end 
  return a end
```



```lua
function Rows:neighbors(row1,the,    a)
  a={}
  for _,row2 in pairs(self.rows) do
    if row1._id ~= row2._id then
       a[ 1+#a ] = {row=row2, dist=row2:dist(row1,the)} end end
  return sort(a,"dist") end
```



```lua
function  Rows:knn(row,the,     a,stats,kadd)
  stats=Sym:new()
  for k,v in pairs(self:neighbors(row,the)) do
    if  k> the.knn then break end
    stats:add(v.row:klass()) 
  end
  kadd={mode=function() return stats.mode end}
  return kadd[the.kadd]()
end
```


stats, number classes ---------------------------------

```lua
local z=1E-32
```



```lua
function Err:new(data,rx)
  return Obj.new(self,"Err",{
    data = data or "data", rx= rx or "rx", _mre=Num()}) end 
```



```lua
function Err:add(want,got) 
  mre:add(math.abs(want-got)/want) end
```



```lua
function Err:mre() 
  return self._mre:mid() end
```


stats, discrete classes ---------------------------------

```lua
function Abcd:new(data,rx)
  return Obj.new(self,"Abcd",{
    data = data or "data", rx= rx or "rx",
    known={}, a={}, b={}, c={}, d={}, yes=0, no=0}) end
```



```lua
function Abcd:exists(x) 
  if inc(self.known,x) == 1 then 
    self.a[x] = self.yes + self.no
    self.b[x] = 0
    self.c[x] = 0
    self.d[x] = 0 end end
```



```lua
function Abcd:add(want,got) 
  self:exists(want) 
  self:exists(got)  
  if   want==got then self.yes=self.yes+1 else self.no=self.no+1 end
  for x,_ in pairs( self.known ) do 
    if   want==x
    then inc(want==got and self.d or self.b, x)
    else inc(got ==x   and self.c or self.a, x) end end end
```



```lua
function Abcd:stats(   p,out,a,b,c,d,pd,pf,pn,f,acc,g,prec)
  p   = function (z) return math.floor(100*z+0.5) end
  z   = function (z) return z==0 and "" or z end
  out = {{"data","rx","n","a","b","c","d","acc","prec",
          "pd","pf","f","g","class"}}
  for x in sorted( self.known ) do
    pd,pf,pn,prec,g,f,acc = 0,0,0,0,0,0,0
    a= self.a[x]; b= self.b[x]; c= self.c[x]; d= self.d[x];
    if b+d > 0     then pd   = d     / (b+d)        end
    if a+c > 0     then pf   = c     / (a+c)        end
    if a+c > 0     then pn   = (b+d) / (a+c)        end
    if c+d > 0     then prec = d     / (c+d)        end
    if 1-pf+pd > 0 then g=2*(1-pf) * pd / (1-pf+pd) end 
    if prec+pd > 0 then f=2*prec*pd / (prec + pd)   end
    if self.yes + self.no > 0 then 
       acc= self.yes / (self.yes + self.no) end
    out[x] = {data=self.data, rx=self.rx, n=self.yes+self.no, 
              a=z(a),b=z(b),c=z(c),d=z(d),acc=p(acc),
              prec=p(prec), pd=p(pd), pf=p(pf), 
              f=p(f),g=p(g),klass=x} end
  return out end
```



```lua
function Abcd:report(stats,     all,m)
  stats = stats or self:stats()
  m     = {}
  all   = {"data","rx","n","a","b","c","d",
           "acc","prec","pd","pf","f","g","klass"}
  m[1]  = all
  linem(m)
  for _,klass in pairs(stats) do
    m[1+#m] = {}
    for i,s in sorted(all) do m[#m][i]=klass[s] end end
  printm(m) end
```


- xxxx make this symbolic. change printm  for that
------------------------------------------------------
## Functions

```lua

```

### List Functions

```lua
function eq(a,b,    ta,tb)
   ta, tb = type(a), type(b)
   if ta ~= tb                              then return false end
   if ta ~= 'table' and tb ~= 'table'       then return t1 == t2 end
   for k,v in pairs(a) do if not eq(v,b[k]) then return false end end
   for k,v in pairs(b) do if not eq(v,a[k]) then return false end end
   return true
end
```



```lua
function shuffle(a,     j)
  for i = #a, 2, -1 do
    j = randi(1,i)
    a[i], a[j] = a[j], a[i] end 
  return a end
```



```lua
function sorted(t,         i,keys)
  i,keys = 0,{}
  for k in pairs(t) do keys[#keys+1] = k end
  table.sort(keys)
  return function ()
    if i < #keys then
      i=i+1; return keys[i], t[keys[i]] end end end
```



```lua
function sort(a,f)
  f = fun(f)
  table.sort(a, function(x,y) return f(x)<f(y) end)
  return a end
```



```lua
function per(a,p) 
  return a[math.max(1,math.floor(#a*(p or .5)))] end
```



```lua
function inc(t,k,n)
  t[k] = (t[k] or 0) + (n or 1)
  return t[k] end
```



```lua
function max(t,k,n) t[k] = math.max(n or 0, (t[k] or 0)) end
```


### Meta Functions

```lua

function fun(f)
  if type(f)=="string" then return function(z) return z[f] end end
  return f and f or function(z) return z end end
```



```lua
function map(a,f,     b)
  b, f = {}, fun(f)
  for i,v in pairs(a or {}) do b[i] = f(v) end 
  return b end 
```



```lua
function copy(obj, seen,      s, res)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  s = seen or {}
  res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res end
```



```lua
local function exports(out,i)
  i,out = 1,out or {}
  while true do
    local s, x = debug.getlocal(2, i)
    if s== nil then break end
    if s:sub(1,1):match("^[A-Z]") then out[s]=x end
    i = 1 + i end
  return out end
```



```lua
local id=0
function Obj.new(self, name, new)
  new = setmetatable(new or {}, self)
  self.__tostring = dump 
  self.__index    = self
  self._name      = name
  id = id + 1
  new._id = id
  return new end
```


### String functions

```lua
function fmt(s,...) return io.write(s:format(...)) end 
```



```lua
function color(s,...)
  local x={red=31, green=32, yellow=33, purple=34}
  print('\27[1m\27['..x[s]..'m'..string.format(...)..'\27[0m') end
```



```lua
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
```



```lua
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
```



```lua
function pump(o) print(dump(o)) end
```



```lua
function linem(m)
  m[#m+1]={}
  for i,x in pairs(m[#m-1]) do 
    m[#m][i] = string.rep("-",math.max(2,#tostring(x))) end end
    
function printm(m,     most,s)
  most = {}
  for _,row in pairs(m) do
    for i,x in pairs(row) do max(most,i, #tostring(x)) end end
  for _,row in pairs(m) do
    s=""
    for i,x in pairs(row) do fmt("%s%".. most[i].."s", s,x);s=" | " end 
    print("") end end
```


### Maths Functions

```lua
function rnd(num, decimals,      mult)
  mult = 10^(decimals or 0)
  return math.floor(num * mult + 0.5) / mult end
```



```lua
function normal(mu,sd)
  local sqrt, log, cos, pi = math.sqrt, math.log, math.cos, math.pi
  return mu+sd*sqrt(-2*log(rand()))*cos(2*pi*rand()) end
```



```lua
Seed = 10013
function randi(lo,hi) return math.floor(rand(lo,hi)) end
```



```lua
function rand(lo,hi,     mult,mod)
  lo,hi = lo or 0, hi or 1
  mult, mod = 16807, 2147483647
  Seed = (mult * Seed) % mod 
  return lo + (hi-lo) * Seed / mod end 
```


### File functions

```lua
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
```


###  Start-up functions

```lua
local fails=0
function run(txt,the,      it)
  the  = copy(the)
  Seed = the.seed
  it   = Eg[txt]
  if     the.un==true 
  then   print("unsafe:"); it.fun(the)
  elseif pcall(function () it.fun(the); end)
  then   color("green","✔ % -15s  %s",txt,it.txt); 
  else   color("red",  "✘ %-15s  %s" ,txt,it.txt); fails=fails+1 end end
```



```lua
function main(the)
  if     the.eg=="all"
  then   for txt,meta in sorted(Eg) do run(txt, the) end 
  elseif the.eg=="ls" 
  then   print("\neegs:")
         for x,y in sorted(Eg) do fmt("  %-15s  %s\n",x,y.txt) end 
  elseif the.eg and Eg[the.eg] 
  then   run(the.eg, the) end end
```


`cli()` creates  command line flags by mapping `config` to `:flags`
or `:options` calls to `argparse`.  By convention, boolean options
default  to false and their  command-line  flag flips them to `true`.
Also, if reading  a numeric option from  command line, remember to
coerce it to a number.

```lua
local function cli(about,       arg,b4)
  --arg = argparse(about.usage, about.synopsis)
  arg = argparse(about.usage, about.synopsis)
  for flag,v in sorted(about.options) do
    flag = "--"..flag
    b4 =" (default: "..tostring(v[1])..")"
    if     v[1]==false
    then   arg:flag(flag, v[2],  v[1]) -- handling Boolean
    elseif type(v[1])=="number"
    then   arg:option(flag, v[2]..b4, v[1],tonumber) -- coerce nums
    else   arg:option(flag, v[2]    , v[1]) end end 
  return arg:parse() end
```


---------------------------------------------------
## Unit Tests

```lua

Eg.shuffle= {
  txt = "shuffling items",
  fun = function(_,     x) 
          x= shuffle({10,20,30,40,50,60})
          assert(x[1] == 20) end }
```



```lua
Eg.sorted= {
  txt = "sorting items",
  fun = function(_) 
         for x,y in sorted{mm=10,zz=2,cc=3,aa=1} do 
           return assert(x=="aa" and y==1)  end end}
```



```lua
Eg.sort= {
  txt= "more sorting",
  fun= function(_,       t) 
         t= sort({{k=10,v=1},{k=3,v=20},{k=1,v=10},{k=5,v=5}},"k")
         assert(5==t[3].v) end}
```



```lua
Eg.map= {
  txt="meta map functions",
  fun=function(_,  f) 
        f= function(z) return z*2 end
        assert(40 ==  map({10,20,30},f)[2]) end}
```



```lua
Eg.copy= {
  txt="deep copy",
  fun=function(_,        a,b) 
               a={1,{2,{3,{4},5},6},7}
               b=copy(a)
               a[2][2][2][1]=10 
        assert(b[2][2][2][1]==4) end}
```



```lua
Eg.num={
  txt="number",
  fun=function(_,     n)
        n=Num:new()
        for i=1,10000 do n:add(rnd(rand(),2)) end
        n:var() end}
        
Eg.rand={
  txt="random numbers",
  fun=function(_,      a)
        a={}; for i=1,10 do a[1+#a]=rnd(rand(),2) end 
        assert(0.08 == sort(a)[3] ) end}
        
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
        assert(math.abs(mu - num:mid()) < eps) end}
```



```lua
Eg.sym={
  txt="entropy",
  fun=function(_,        e0,e1,eps)
        e0, eps = 1.3787834, 0.0001
        assert(0==adds({"a","a","a","a"}):var())
        e1 =adds({"a","a","a","a","b","b","c"}):var()
        assert(math.abs(e1 - e0) < eps) end}
```



```lua
Eg.csv={
  txt="loading csv",
  fun=function(the,       n)
        for row in csv(the.data) do 
          n  = n or #row
          assert(n==#row)  end end}
```



```lua
Eg.clone={
  txt="cloning a table",
  fun=function(the,       t1,t2)
    the.data =  "../data/weathernom.csv"
    t1 = Rows:new():read(the.data)
    t2 = t1:clone(t1.rows)
    assert(eq(t1.cols, t2.cols))
  end }
```



```lua
Eg.dist={
  txt="checking distances",
  fun=function(the,       t,a)
    the.data =  "../data/auto2.csv"
    t = Rows:new():read(the.data)
    for i,row1 in pairs(t.rows) do
      fmt("%3s %s", i, i%20==0 and "\n" or "")
      a = t:neighbors(row1,the)
      assert(a[1].dist < a[#a].dist) end
    assert(t.cols.all[1].most==8)
    assert(t.cols.all[1].mode=="Chevrolet")
    end}
```



```lua
Eg.abcd={
  txt="collecting stats on discrete classes",
  fun=function(the,    a)
    a = Abcd:new()
    for i=1,6 do a:add('y','y') end
    for i=1,2 do a:add('n','n') end
    for i=1,5 do a:add('m','m') end
    a:add('m','n')
    a:report() end }
 
```

```
db |    rx |   num |     a |     b |     c |     d |  acc |  pre |   pd |   pf |    f |    g | class
---- |  ---- |  ---- |  ---- |  ---- |  ---- |  ---- | ---- | ---- | ---- | ---- | ---- | ---- |-----
data |    rx |    14 |    11 |       |     1 |     2 | 0.93 | 0.67 | 1.00 | 0.08 | 0.80 | 0.96 | no
data |    rx |    14 |     8 |       |       |     6 | 0.93 | 1.00 | 1.00 | 0.00 | 1.00 | 1.00 | yes
data |    rx |    14 |     8 |     1 |       |     5 | 0.93 | 1.00 | 0.83 | 0.00 | 0.91 | 0.91 | maybe
```

```lua

local function  rows(file,      t)
  t={}
  for row in csv(file) do t[1+#t] = row end
  return t end
```



```lua
local function classincify(t,the,rx,fun,       t2,rows)
  results = Abcd:new(the.data,rx)
  rows = shuffle(t.rows)
  some = t:clone()
  for i=1,n do some:add(rows[i]) end
  for i=n+1,#rows do
    row = Row:new( rows[i], some)
    results:add( row:klass(), fun(some, row,the) ) 
  end
  return results end
```



```lua
Eg.knndiabetes={
  txt="checking distances",
  fun=function(the,       t,a)
    the.data =  "../data/diabetes.csv"
    t = Rows:new():read(the.data)
    t.rows = shuffle(t.rows)
    print(#t.rows)
    end}
```



```lua

local function classify(rows,the,rx,fun,       t,results,row)
  t = Rows:new()
  results = Abcd:new(the.data,rx)
  for _,row0 in pairs(rows) do
    if #t.rows > the.wait then
      row = Row:new( row0, t)
      results:add( row:klass(), fun(t, row,the) ) 
    end
    t:add(row0) 
  end 
  return results end
```



```lua
Eg.knn={
  txt="test nearest neighbor",
  fun=function(the, results)
        the.data = "../data/diabetes.csv"
        results= classify(rows(the.data),
                            the, "knn"..tostring(the.knn), 
                  function (t,row,the) 
                    return t:knn(row,the) end) 
        results:report() end}
```


----------------------------------------------------------
## Start-up

```lua
main( cli(about))
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
os.exit(fails) 
