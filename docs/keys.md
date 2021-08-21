
#  



      ,-_|\   keys
     /     \  (c) Tim Menzies, 2021, unlicense.org
     \_,-._*  Cluster, then report just the 
          v   deltas between nearby clusters.  


<ul><details><summary>code</summary>



```lua


local argparse = require("argparse")
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
-----------------------------------------------
```

</details></ul>


## About
All the `options` are available as command line flags, e.g.


<ul><details><summary>code</summary>



```lua

--
```

</details></ul>


      ./keys --bins 10 --loud


<ul><details><summary>code</summary>



```lua

--
```

</details></ul>


Boolean options have no  arguments (e.g. `loud`). Mentioning
booleans    on the command line will set that option to `true`.
 
The `--eg X` runs the unit tests. Use `--eg ls`  to list those
tests. ``--eg all``  will run all tests. 


<ul><details><summary>code</summary>



```lua

--
```

</details></ul>


If a test  crashes,
and  you  want to see  the  stacktrace, run the  test again in 
`wild` mode; e.g


<ul><details><summary>code</summary>



```lua

--
```

</details></ul>


    ./bins --wild --eg abcd


<ul><details><summary>code</summary>



```lua

--
```

</details></ul>


### The `the` variable.
The config  options  are never set  globally. Rather, they
are carried  around in  a local variable  called `the`. In
this way, different parts  of the code could use different  config
settings.


<ul><details><summary>code</summary>



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
        bins= { .5    ,'Bins are of size n**BINS'},
        bootstrap={512,'number of bootstrap samples'},
        cols= {'x'    ,'Columns to use for inference'},
        conf=  {0.05,   "confidence for bootstraps"},
        cliffs={ .147 ,"small effect "},
        data= {'../data/auto2.csv' 
                      ,'Where to read data'},
        eg=   {""     ,"'-x ls' lists all, '-x all' runs all"},
        far=  { .9    ,'Where to look for far things'},
        goaL= {'best' ,'Learning goals: best|rest|other'},
        iota= { .3    ,'Small = sd**iota'},
        k=    {2      ,'Bayes low class frequency hack'},
        knn=  {2      ,'Number of neighbors for knn'},
        kadd= {"mode", "combination rule of knn"},
        loud= {false  ,'Set verbose'},
        m=    {1      ,'Bayes low range frequency hack'},
        p=    {2      ,'Distance calculation exponent'},
        sames={256    ,"max size of nonparametric samples"},
        some= {20     ,'Number of samples to find far things'},
        seed= {10013  ,'Seed for random numbers'},
        top=  {10     ,'Focus on this many'},
        wild= {false  ,'Run egs, no protection (wild mode)'},
        wait= {10     ,'Pause before thinking'}}}
      
---------------------------------------------------------
```

</details></ul>


##  Classes
`Obj`  is  the class creation factor. `Eg` stores the
unit and  system tests.


<ul><details><summary>code</summary>



```lua

local Obj,Eg       = {},{}     
```

</details></ul>


Columns. `Skip` is for columns we want to ignoe
the  others are for columns of  `Num`bers  or  `Sym`bols.


<ul><details><summary>code</summary>



```lua

local Skip,Num,Sym = {},{},{}  
```

</details></ul>


`Rows` is a  container  classes that holds
`Row`s and column summaries.


<ul><details><summary>code</summary>



```lua

local Row,Rows      = {},{}    
```

</details></ul>


Reporting.


<ul><details><summary>code</summary>



```lua

local Err,Abcd = {},{},{}   
```

</details></ul>


## Functions


<ul><details><summary>code</summary>



```lua

```

</details></ul>


For columns.


<ul><details><summary>code</summary>



```lua

local goalp,klassp,nump,weight,skipp,merged,adds 
```

</details></ul>


Meta functions


<ul><details><summary>code</summary>



```lua

local fun,locals,scottKnot            
```

</details></ul>


 For lists.


<ul><details><summary>code</summary>



```lua

local eq,top,sorted,sort,map,copy,per,shuffle,inc,max
```

</details></ul>


 For Stats on lists.


<ul><details><summary>code</summary>



```lua

local sample,samples,cliffsDelta ,same,bootstrap
```

</details></ul>


 For strings.


<ul><details><summary>code</summary>



```lua

local fmt,color,dump,rump,pump,linem,printm   
```

</details></ul>


For maths.


<ul><details><summary>code</summary>



```lua

local rnd,Seed,rand,randi,normal,merges   
```

</details></ul>


 For  files.


<ul><details><summary>code</summary>



```lua

local csv                  
```

</details></ul>


 Code  called at start-up.


<ul><details><summary>code</summary>



```lua

local run,main        

-------------------------------------------------------------
```

</details></ul>


## columns, general


<ul><details><summary>code</summary>



```lua

```

</details></ul>


This code reads tables of data where line1 shows the name
for each column. For example:


<ul><details><summary>code</summary>



```lua

--
```

</details></ul>


    name?, Age, Shoesize, Job,  Salary+ YearsOnJob-
    tim,   21,  10,       prof, 100,     100
    jane,  60,  10,       hod,  1000,    10
    ...    ..   ..        ..    ..       ..


<ul><details><summary>code</summary>



```lua

--
```

</details></ul>


Note that the row1 names have magic symbols.
Numerics start with uppercase. Goals to be minimize or
maximized end with `-` and `+` (respectively). Columns
to be ignored contain `?`. Columns usually have a `weight`
of "1" unless we are minimizing them in which case that is "-1".


<ul><details><summary>code</summary>



```lua

--

function klassp(s) return s:find("!") end
function goalp(s)  return s:find("+") or s:find("-") or klassp(s) end
function nump(s)   return s:sub(1,1):match("[A-Z]") end
function weight(s) return s:find("-") and -1 or 1 end
function skipp(s)  return s:find("?") end
```

</details></ul>


Each column (except for `Skip`) needs its own version of the
following:


<ul><details><summary>code</summary>



```lua

--
```

</details></ul>


- `:add()`  : add `x` to the column;
- `:dist()` : returns probability that `x` belongs to the
- `:like()` : returns distance between two values in this column.
- `:merge()` : combine two columns
- `:mid()` : return the central tendency of a  column
- `:new()`  : returns a new column
- `:var()` : reports how values can vary around the `mid`.


<ul><details><summary>code</summary>



```lua

```

</details></ul>


The following functions work for all columns.
 `adds()` lets you create one or update a `col`umn with a list of
column `a`  (and if creating, then it guesses column type from the
first entry).


<ul><details><summary>code</summary>



```lua

function adds(a,col) 
  col = col or (type(a[1])=="number" and Num or Sym):new()
  for _,x in pairs(a) do col:add(x) end 
  return col end
```

</details></ul>


Finally, `merged()` checks if life is simpler if we combine two columns.


<ul><details><summary>code</summary>



```lua

function merged(i,j,         k)
  k= i:merge(j)
  if k:var() < (i.n*i:var() + j.n*j:var()) / (i.n + j.n) then 
    return k end end

------------------------------------------------------------
```

</details></ul>


## Specific Columns
### Skip 
Columns for data that we just want to ignore.


<ul><details><summary>code</summary>



```lua


function Skip:new(at,s) 
  return Obj.new(self,"Skip",{
    n=0, s=s or "", at=at or 0}) end

function Skip: add(x) return  x end

function Skip: like(x,_) return 1 end

------------------------------------------------------------
```

</details></ul>


### Sym
Symbolic columns keep symbol counts (in `has`) and know
the `mode` (most common) value.


<ul><details><summary>code</summary>



```lua


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
```

</details></ul>


Variance of symbols is called entropy.


<ul><details><summary>code</summary>



```lua

function Sym:var(x,     e,p)
  e= 0
  p= function(n) return n/self.n end
  for _,v in pairs(self.has) do e=e - p(v)*math.log(p(v),2) end 
  return e end

function Sym:dist(x,y) return x==y and 0 or 1 end

------------------------------------------------------------
```

</details></ul>


### Num


<ul><details><summary>code</summary>



```lua


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
```

</details></ul>


variance  of numerics  is the  standard deviation.


<ul><details><summary>code</summary>



```lua

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
```

</details></ul>


 If any value missing, guess a value of the other that
maximizes the distance.


<ul><details><summary>code</summary>



```lua

function Num:dist(x,y)
  if     x=="?" then y=self:norm(y); x = y>.5 and 0 or 1 
  elseif y=="?" then x=self:norm(x); y = x>.5 and 0 or 1 
  else               x,y = self:norm(x), self:norm(y) end
  return math.abs(x-y) end
 
function Num:delta(other,    y,z,e)
  y, z, e = self, other, 0
  return math.abs(y:mu() - z:mu()) / (
         (e + y:var()^2/y.n + z:var()^2/z.n)^.5) end
```

</details></ul>


are two distributions the same?


<ul><details><summary>code</summary>



```lua

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

function merges(nums,lo,hi,    out)
  lo = lo or 1
  hi = hi or #nums
  out = nums[lo]
  for i = lo+1, hi do out = out:merge(nums[i]) end
  return out end

--------------------------------------------------
```

</details></ul>


## Row
Store one example.


<ul><details><summary>code</summary>



```lua

function Row:new(a,rows)
  return Obj.new(self,"Row",{cells=a, _rows=rows}) end

function Row:klass() 
  return self.cells[self._rows.cols.klass.at] end

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

</details></ul>


Store many  examples, summarized in columns.


<ul><details><summary>code</summary>



```lua

function Rows:new(inits,     x)
  x= Obj.new(self,"Rows",{
      rows={}, keep=true,
      cols={all={},names={},x={},y={}}})
  for _,row in pairs(inits or {}) do x:add(row) end  
  return x end
```

</details></ul>


clone a copy 


<ul><details><summary>code</summary>



```lua

function  Rows:clone(inits,    t)
  t = Rows:new({self.cols.names})
  for _,x in pairs(inits or {}) do 
    t:add(x) end
  return t end
```

</details></ul>


Read from a file


<ul><details><summary>code</summary>



```lua

function Rows:read(f) 
  for row in csv(f) do self:add(row) end 
  return self end
```

</details></ul>


If this is row1, create the header. Else, add new data.


<ul><details><summary>code</summary>



```lua

function Rows:add(a)
   a = (a._name and a._name=="Row" and a.cells) or a
   if   #(self.cols.names) > 0 
   then return self:data(a) 
   else return self:header(a) end end
```

</details></ul>


Update the column summaries. Maybe  keep the new row.


<ul><details><summary>code</summary>



```lua

function Rows:data(a,    row)
  for _,col in pairs(self.cols.all) do 
     a[col.at]=col:add(a[col.at]) end
  if self.keep then
    row = Row:new(a,self) 
    self.rows[ 1 + #self.rows] = Row:new(a,self) end 
  return row end
```

</details></ul>


Read the magic symbols, make the appropriate columns,
store them in the right  places.


<ul><details><summary>code</summary>



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

function Rows:neighbors(row1,the,    a)
  a={}
  for _,row2 in pairs(self.rows) do
    if row1._id ~= row2._id then
       a[ 1+#a ] = {row=row2, dist=row2:dist(row1,the)} end end
  return sort(a,"dist") end

function Rows:knn(row,the,     a,stats,kadd,all,one)
  stats=Sym:new()
  all= self:neighbors(row,the)
  for i = 1,the.knn do 
    one = all[i].row
    stats:add( one:klass() ) end
  kadd={mode=function() return stats.mode end}
  return kadd[the.kadd]()
end

local Learn={}
function Learn:new(opt)
  opt.log = opt.log or Abcd:new(opt.data or "",opt.rx or "")
  return Obj.new(self,"Learn", {n=0,
    trainer=opt.train, tester=opt.test, log=opt.log}) end

function Learn:inc(row,the)
  self:test( row,the)
  self:train(row,the)  end

function Learn:train(row,the) 
  self.n = self.n + 1
  return self.trainer(row,the) end

function Learn:test(row,the,       want,got)
  if self.n > the.wait then
    want = row:klass()
    got  = self.tester(row,the)
    self.log:add( want, got) end end
```

</details></ul>


stats, number classes ---------------------------------


<ul><details><summary>code</summary>



```lua

local z=1E-32

function Err:new(data,rx)
  return Obj.new(self,"Err",{
    data = data or "data", rx= rx or "rx", _mre=Num()}) end 

function Err:add(want,got) 
  mre:add(math.abs(want-got)/want) end

function Err:mre() 
  return self._mre:mid() end
```

</details></ul>


stats, discrete classes ---------------------------------


<ul><details><summary>code</summary>



```lua

function Abcd:new(data,rx)
  return Obj.new(self,"Abcd",{
    data = data or "data", rx= rx or "rx",
    known={}, a={}, b={}, c={}, d={}, yes=0, no=0}) end

function Abcd:exists(x) 
  if inc(self.known,x) == 1 then 
    self.a[x] = self.yes + self.no
    self.b[x] = 0
    self.c[x] = 0
    self.d[x] = 0 end end

function Abcd:add(want,got) 
  self:exists(want) 
  self:exists(got)  
  if   want==got then self.yes=self.yes+1 else self.no=self.no+1 end
  for x,_ in pairs( self.known ) do 
    if   want==x
    then inc(want==got and self.d or self.b, x)
    else inc(got ==x   and self.c or self.a, x) end end end

function Abcd:stats(   p,out,a,b,c,d,pd,pf,pn,f,acc,g,prec)
  p   = function (z) return math.floor(100*z+0.5) end
  z   = function (z) return z==0 and "" or z end
  out = {}
  for x,_ in pairs( self.known ) do
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
    out[x] = {data=self.data, rx=self.rx, n=self.b[x]+self.d[x],
              a=z(a),b=z(b),c=z(c),d=z(d),acc=p(acc),
              prec=p(prec), pd=p(pd), pf=p(pf), 
              f=p(f),g=p(g),klass=x} end
  return out, {"data","rx","n","a","b","c","d",
               "acc","prec", "pd","pf","f","g","klass"} end

function Abcd:report(      stats,head,all,m,klass)
  stats,all = self:stats()
  m    = {}
  m[1] = all
  linem(m)
  for x in sorted(stats) do
    klass = stats[x]
    m[1+#m] = {}
    for i,s in sorted(all) do m[#m][i]=klass[s] end end
  printm(m) end
```

</details></ul>


Rank ------------------------------------------------------


<ul><details><summary>code</summary>



```lua

function scottKnot(nums,the,      _,mu,cohen,summary,div)
  function summary(lo,hi,    out)
    out = merges(nums,lo,hi)
    return out, out:mu(), out:var()*the.iota end

  function recurse(lo, hi, rank, mu,
               _,n,cut,best,l,r,lmu,lmu1,rmu,rmu1,now)
    best = 0
    for j = lo,hi do
      if j < hi  then
        l, lmu, _ = summary(lo,  j)
        r, rmu, _ = summary(j+1, hi)
        n         = l.n + r.n
        now       = l.n/n*(lmu-mu)^2 + r.n/n*(rmu-mu)^2
        if now > best then
          if math.abs(lmu - rmu) >= cohen then
            if not l:same(r,the) then
              cut,best,lmu1,rmu1 = j,now,lmu,rmu end end end end
    end
    if cut then
      rank = recurse(lo,    cut, rank, lmu1) + 1
      rank = recurse(cut+1, hi,  rank, rmu1) 
    else
      for i = lo,hi do nums[i].rank = rank end end
    return rank end
  -------------------
  table.sort(nums, function (x,y) return x:mu() < y:mu() end) 
  _, mu, cohen = summary(1,#nums)
  recurse(1, #nums, 1, mu)
  return nums end

--------------------------------------------------------
```

</details></ul>


## Functions


<ul><details><summary>code</summary>



```lua

```

</details></ul>


### List Functions


<ul><details><summary>code</summary>



```lua

function eq(a,b,    ta,tb)
   ta, tb = type(a), type(b)
   if ta ~= tb                              then return false end
   if ta ~= 'table' and tb ~= 'table'       then return a == b end
   for k,v in pairs(a) do if not eq(v,b[k]) then return false end end
   for k,v in pairs(b) do if not eq(v,a[k]) then return false end end
   return true
end
```

</details></ul>


shuffles, in place the table `a`


<ul><details><summary>code</summary>



```lua

function shuffle(a,n,    j)
  for i = #a, 2, -1 do
    j = randi(1,i)
    a[i], a[j] = a[j], a[i] end
  return n and top(a, n) or a end
```

</details></ul>


pull one items from `t`


<ul><details><summary>code</summary>



```lua

function sample(t) 
  return t[randi(1,#t)] end
```

</details></ul>


samples with replacement, from list `t`.


<ul><details><summary>code</summary>



```lua

function samples(t,n,    t1)
  t1 = {}
  for i=1,n or #t do t1[i] = sample(t) end
  return t1 end

function top(a,n,         b) 
  b={}
  for i=1, math.min(n,#a) do b[i] = a[i] end
  return b end

function sorted(t,         i,keys)
  i,keys = 0,{}
  for k in pairs(t) do keys[#keys+1] = k end
  table.sort(keys)
  return function ()
    if i < #keys then
      i=i+1; return keys[i], t[keys[i]] end end end

function sort(a, f)
  f = fun(f)
  table.sort(a, function(x,y) return f(x)<f(y) end)
  return a end

function per(a,p) 
  return a[math.max(1,math.floor(#a*(p or .5)))] end

function inc(t,k,n)
  t[k] = (t[k] or 0) + (n or 1)
  return t[k] end

function max(t,k,n) t[k] = math.max(n or 0, (t[k] or 0)) end

function same(xs,ys, the)
  if #xs > the.sames then xs = shuffle(xs, the.sames) end
  if #ys > the.sames then ys = shuffle(ys, the.sames) end
  return cliffsDelta(xs,ys,the) and bootstrap(xs,ys, the) end
```

</details></ul>


Non parametric effect size test (i.e. are two distributions
different by more than a small amount). Slow for large lists
(hint: sub-sample large lists).  Thresholds here set from
top of p14 of  https://bit.ly/3m9Q0pP .  0.147 (small), 0.33
(medium), and 0.474 (large)


<ul><details><summary>code</summary>



```lua

function cliffsDelta(xs,ys,the,       lt,gt)
  lt,gt = 0,0
  for _,x in pairs(xs) do
    for _,y in pairs(ys) do
      if y > x then gt = gt + 1 end
      if y < x then lt = lt + 1 end end end
  return math.abs(gt - lt)/(#xs * #ys) <= the.cliffs end
```

</details></ul>


Non parametric "significance"  test (i.e. is it possible to
distinguish if an item belongs to one population of
another).  Uses a sampling with replacement. Warning: very
slow for large populations. Consider sub-sampling  for large
lists. Also, test the effect size (and maybe shortcut the
test) before applying  this test.  From p220 to 223 of the
Efron text  'introduction to the boostrap'.
https://bit.ly/3iSJz8B Typically, conf=0.05 and b is 100s to
1000s.


<ul><details><summary>code</summary>



```lua

function bootstrap(y0,z0,the,     x,y,z,xmu,ymu,zmu,yhat,zhat,tobs,n)
  x, y, z, yhat, zhat = Num:new(), Num:new(), Num:new(), {}, {}
  for _,y1 in pairs(y0) do x:add(y1); y:add(y1)           end
  for _,z1 in pairs(z0) do x:add(z1); z:add(z1)           end
  xmu, ymu, zmu = x:mu(), y:mu(), z:mu()
  -- translate both samples so that they have mean x, 
  -- the re-sample each population separately.
  for _,y1 in pairs(y0) do yhat[1+#yhat] = y1 - ymu + xmu end
  for _,z1 in pairs(z0) do zhat[1+#zhat] = z1 - zmu + xmu end
  tobs = y:delta(z)
  n = 0
  for _= 1,the.bootstrap do
    if adds(samples(yhat)):delta(adds(samples(zhat))) > tobs 
    then n = n + 1 end end
  return n / the.bootstrap >= the.conf end
```

</details></ul>


### Meta Functions


<ul><details><summary>code</summary>



```lua

function fun(f)
  if type(f)=="string" then return function(z) return z[f] end end
  return f and f or function(z) return z end end

function map(a,f,     b)
  b, f = {}, fun(f)
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

local function exports(out,i)
  i,out = 1,out or {}
  while true do
    local s, x = debug.getlocal(2, i)
    if s== nil then break end
    if s:sub(1,1):match("^[A-Z]") then out[s]=x end
    i = 1 + i end
  return out end

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

</details></ul>


### String functions


<ul><details><summary>code</summary>



```lua

function fmt(s,...) return io.write(s:format(...)) end 

function color(s,...)
  local x={red=31, green=32, yellow=33, purple=34}
  print('\27[1m\27['..x[s]..'m'..string.format(...)..'\27[0m') end

function dump(t,     sep,s)
  if (#t > 0) then
    return table.concat(t,",") end
  sep, s = "", (t._name or "") .."{"
  for k,v in sorted(t) do 
    if k:sub(1,1) ~= "_" then
      s=s .. sep .. tostring(k).."="..tostring(v)
      sep=", " end end 
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

</details></ul>


### Maths Functions


<ul><details><summary>code</summary>



```lua

function rnd(num, decimals,      mult)
  mult = 10^(decimals or 0)
  return math.floor(num * mult + 0.5) / mult end

function normal(mu,sd)
  local sqrt, log, cos, pi = math.sqrt, math.log, math.cos, math.pi
  return mu+sd*sqrt(-2*log(rand()))*cos(2*pi*rand()) end

Seed = 10013
function randi(lo,hi) return math.floor(rand(lo,hi)) end

function rand(lo,hi,     mult,mod)
  lo,hi = lo or 0, hi or 1
  mult, mod = 16807, 2147483647
  Seed = (mult * Seed) % mod 
  return lo + (hi-lo) * Seed / mod end 
```

</details></ul>


### File functions


<ul><details><summary>code</summary>



```lua

function csv(file,rows,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      tmp = tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      t={}; for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if #t > 0 then
        for j,x in pairs(t) do t[j]=tonumber(x) or x end
        return rows and Row:new(t,rows) or t end
    else
      io.close(stream) end end end
```

</details></ul>


###  Start-up functions


<ul><details><summary>code</summary>



```lua

local fails=0
function run(txt,the,      it)
  the  = copy(the)
  Seed = the.seed
  it   = Eg[txt]
  if     the.wild==true 
  then   color("yellow", "now running wild:"); it.fun(the)
  elseif pcall(function () it.fun(the); end)
  then   color("green","✔ % -15s  %s",txt,it.txt); 
  else   color("red",  "✘ %-15s  %s" ,txt,it.txt); fails=fails+1 end end

function main(the)
  if     the.eg=="all"
  then   for txt,meta in sorted(Eg) do run(txt, the) end 
  elseif the.eg=="ls" 
  then   print("\neegs:")
         for x,y in sorted(Eg) do fmt("  %-15s  %s\n",x,y.txt) end 
  elseif the.eg and Eg[the.eg] 
  then   run(the.eg, the) end end
```

</details></ul>


`cli()` creates  command line flags by mapping `config` to `:flags`
or `:options` calls to `argparse`.  By convention, boolean options
default  to false and their  command-line  flag flips them to `true`.
Also, if reading  a numeric option from  command line, remember to
coerce it to a number.


<ul><details><summary>code</summary>



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

-----------------------------------------------------
```

</details></ul>


## Unit Tests


<ul><details><summary>code</summary>



```lua


Eg.eq={
  txt="recursive equals",
  fun=function(_,      a,b,c)
         a={10,{d=100},{c=30},{1,{2,{3,{4,6}}}}}
         b={10,{d=100},{c=30},{1,{2,{3,{4,6}}}}}
         c={10,{d=100},{c=30},{1,{2,{3,{4,10 -- difference here
                           }}}}}
         print(eq(a,b))
         print(not eq(a,c))
      end}

Eg.top= {
  txt = "shuffling items",
  fun = function(_,     x) 
          x= top({"a","b","c","d","e",
                     "f","g","h","i","j",
                     "0","1","2","3","4","5",
                     "6","7","8","9" },8) 
          assert(x[#x] == "h") end }

Eg.shuffle= {
  txt = "shuffling items",
  fun = function(_,     x) 
          x= shuffle({"a","b","c","d","e",
                     "f","g","h","i","j",
                     "0","1","2","3","4","5",
                     "6","7","8","9" }) 
          print(table.concat(x))
          assert(x[1] == "2") end }

Eg.samples= {
  txt = "sample items, with replacement",
  fun = function(_,     x) 
          x= samples({"a","b","c","d","e",
                     "f","g","h","i","j",
                     "0","1","2","3","4","5",
                     "6","7","8","9" }) 
          print(table.concat(x))
          assert(x[1] == "b") end }

Eg.sorted= {
  txt = "sorting items",
  fun = function(_) 
         for x,y in sorted{mm=10,zz=2,cc=3,aa=1} do 
           return assert(x=="aa" and y==1)  end end}

Eg.sort= {
  txt= "more sorting",
  fun= function(_,       t) 
         t= sort({{k=10,v=1}, {k=3,v=20}, {k=1,v=10}, {k=5,v=5}},"k")
         assert(5==t[3].v) end}

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
        assert(b[2][2][2][1]==4) end}

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

Eg.sym={
  txt="entropy",
  fun=function(_,        e0,e1,eps)
        e0, eps = 1.3787834, 0.0001
        assert(0==adds({"a","a","a","a"}):var())
        e1 =adds({"a","a","a","a","b","b","c"}):var()
        assert(math.abs(e1 - e0) < eps) end}

Eg.csv={
  txt="loading csv",
  fun=function(the,       n)
        for row in csv(the.data) do 
          n  = n or #row
          assert(n==#row)  end end}

local function same1(a,b,the,n)
  the.sames=n
  return same(a,b,the)
end

Eg.cliffs={
  txt="nonparametric effect size",
  fun=function(the,     a,b,n)
        for _,n in pairs {20,40,80,160,320,640} do
          print(n)
          for _, delta in pairs {1,1.01,1.025,1.05,
                                 1.1,1.15,1.2,1.4,1.8} do
            a,b={},{}
            for i=1,n do a[i] = randi(1,100)^.5; b[i]=a[i]*delta  end
            print("\t",delta, n, 
                      cliffsDelta(a,b,the),
                      bootstrap(  a,b,the),
                      same(       a,b,the),
                      same1(      a,b,the,128)) 
                      end end end }

Eg.same={
  txt="numbers",
  fun=function (the,      t,t1,t2)
        t1= adds { 0.34,  0.49,  0.51,  0.6}
        t2= adds { 0.1,   0.2,   0.3,   0.4}
        print(t1:same(t2,the))
      end }

Eg.rank={
  txt="numbers",
  fun=function (the,      t,t1,t2,t3,t4,t5)       
        t1= adds { 0.34,  0.49,  0.51,  0.6}
        t2= adds { 0.6,   0.7,   0.8,   0.9}
        t3= adds { 0.15,  0.25,  0.4,   0.35}
        t4= adds { 0.6,   0.7,   0.8,   0.9}
        t5= adds { 0.1,   0.2,   0.3,   0.4}
        t = {t1, t2, t3, t4, t5}
        ts = merges(t)
        t = scottKnot(t,the)
        for i=1,#t do
          num= t[i]
          print(num:tile(num._all,30).str) end
      end }

Eg.rank1={
  txt="numbers",
  fun=function (the,      t,t1,t2,t3,t4,t5,t6,t7,t8,t9)       
        t1,t2,t3 = Num:new(), Num:new(), Num:new()
        t4,t5,t6 = Num:new(), Num:new(), Num:new()
        t7,t8,t9 = Num:new(), Num:new(), Num:new()
        for i=1,20 do t1:add(  math.floor(randi(1,100)^.5) ) end
        for _,x in pairs(t1._all) do 
          t5:add(1.01*x) 
          t8:add(1.01*x) 
          t9:add(1.01*x) 
          t2:add(1.05*x) 
          t3:add(1.4*x) 
          t6:add(1.4*x) 
          t4:add(1.5*x) 
          t7:add(3.5*x) 
        end
        t= {t1,t2,t3,t4,t5,t6,t7,t8,t9}
        for _,t1 in pairs(scottKnot(t, the)) do 
          print(t1:mid(), t1.rank) end
      end }

Eg.clone={
  txt="cloning a table",
  fun=function(the,       t1,t2)
    the.data =  "../data/weathernom.csv"
    t1 = Rows:new():read(the.data)
    t2 = t1:clone(t1.rows)
    assert(t1.cols.all[1].has.rainy  == t2.cols.all[1].has.rainy)
  end }

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

</details></ul>


```
db |    rx |   num |     a |     b |     c |     d |  acc |  pre |   pd |   pf |    f |    g | class
---- |  ---- |  ---- |  ---- |  ---- |  ---- |  ---- | ---- | ---- | ---- | ---- | ---- | ---- |-----
data |    rx |    14 |    11 |       |     1 |     2 | 0.93 | 0.67 | 1.00 | 0.08 | 0.80 | 0.96 | no
data |    rx |    14 |     8 |       |       |     6 | 0.93 | 1.00 | 1.00 | 0.00 | 1.00 | 1.00 | yes
data |    rx |    14 |     8 |     1 |       |     5 | 0.93 | 1.00 | 0.83 | 0.00 | 0.91 | 0.91 | maybe
```


<ul><details><summary>code</summary>



```lua


local function  file2rows(file,      t)
  t={}
  for row in csv(file) do t[1+#t] = row end
  return t end

local function classinc(n,all,the,rx,fun,       results,rows,some,row)
  results = Abcd:new(the.data,rx)
  rows = shuffle(all.rows)
  some = all:clone()
  n    = math.min(n,#all.rows)
  for i=1,n do some:add(rows[i]) end
  for i=n+1,#rows do
    row = Row:new( rows[i].cells, some)
    results:add( row:klass(), fun(some, row,the) ) 
  end
  return results end
```

</details></ul>


-- do it stochastic. pick variants at random


<ul><details><summary>code</summary>



```lua

Eg.incKnnDiabetes={
  txt="ncrementalDiabetes",
  fun=function(the,       t0,t,row,log,all,pos,neg,stats)
    the.data =  "../data/diabetes.csv"
    t0 = Rows:new():read(the.data)
    pos,neg = {},{}
    for _,n in pairs {32,64} do --128,256,512}) do
      pos[n], neg[n] = Num:new(), Num:new()
      for i = 1,5 do
        print(n,i)
        t   = t0:clone()
        log = Abcd:new()
        all = shuffle(t0.rows)
        for i = 1,n do 
          row = all[i]
          t:add(row) end
        print(222)
        for i = n+1, #all do 
          row = all[i]
          log:add(row:klass(), t:knn(row,the)) end
        stats,_ = log:stats()
        pos[n]:add(stats.positive.pd)
        neg[n]:add(stats.negative.pd) end end end}

Eg.knn={
  txt="basic nearest neighbor",
  fun=function(the,    t,l,  row,log)
        the.data = "../data/diabetes.csv"
        log=Abcd:new()
        t= Rows:new()
        for row in csv(the.data,t) do
          if #t.rows > 10 then
            log:add(row:klass(), t:knn(row, the))
          end
          t:add(row) end
        log:report() end}

Eg.knns={
  txt="test the 'Learn' pattern", 
  fun=function(the,    t,l)
        the.data = "../data/diabetes.csv"
        t= Rows:new()
        l= Learn:new {
             train = function (x,the) t:add(x) end,
             test  = function (x,the) return t:knn(x,the) end}
        for row in csv(the.data, t) do l:inc(row, the) end
        l.log:report() end}

------------------------------------------------------------
```

</details></ul>


## Start-up


<ul><details><summary>code</summary>



```lua

main( cli(about))
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
os.exit(fails) 

```
