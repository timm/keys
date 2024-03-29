#!/usr/bin/env lua
--vim: filetype=lua ts=2 sw=2 sts=2 et :

--  
--       ,-_|\   keys
--      /     \  (c) Tim Menzies, 2021, unlicense.org
--      \_,-._*  Cluster, then report just the 
--           v   deltas between nearby clusters.  

-- package.path = package.path .. ';tools/?.lua'

local argparse = require("argparse")
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
-----------------------------------------------
-- ## About
-- All the `options` are available as command line flags, e.g.
--
--       ./keys --bins 10 --loud
--
-- Boolean options have no  arguments (e.g. `loud`). Mentioning
-- booleans    on the command line will set that option to `true`.
--  
-- The `--eg X` runs the unit tests. Use `--eg ls`  to list those
-- tests. ``--eg all``  will run all tests. 
--
-- If a test  crashes,
-- and  you  want to see  the  stacktrace, run the  test again in 
-- `wild` mode; e.g
--
--     ./bins --wild --eg abcd
--
-- ### The `the` variable.
-- The config  options  are never set  globally. Rather, they
-- are carried  around in  a local variable  called `the`. In
-- this way, different parts  of the code could use different  config
-- settings.

local about = require("about")
local dumps = require("dumps")     
local dump,rump,pump=dumps.dump, dumps.rump, dumps.pump
local Obj = require("obj")
local Eg={}

local _ = require("col")
local klassp,goalp,nump = _.klassp,_.goalp,_.nump
local weight, skipp     = _.weight, _.skipp
local adds, merged      = _.adds, _.merged

local _ = require("tools/list")
local eq,shuffle,top,sorted = _.eq, _.shuffle, _.top, _.sorted
local sort,per,inc,max      = _.sort, _.per, _.inc, _.max

local _ = require("tools/stats")
local sample, samples, same  = _.sample, _,samples, _,same
local cliffsDelta, bootstrap = _.cliffsDelta, _bootstrap
local merges, scottKnot      = _.merges, _.scottKnot

---------------------------------------------------------
-- ##  Classes
-- `Obj`  is  the class creation factor. `Eg` stores the
-- unit and  system tests.
-- Columns. `Skip` is for columns we want to ignoe
-- the  others are for columns of  `Num`bers  or  `Sym`bols.
local Skip,Num,Sym = require "skip", require "num", require "sym"
-- `Rows` is a  container  classes that holds
-- `Row`s and column summaries.
local Row,Rows      = {},{}    
-- Reporting.
local Err,Abcd = {},{},{}   
-- ## Functions
-- Meta functions
local fun,locals,scottKnot            
--  For strings.
local fmt,color,dump,rump,pump,linem,printm   
-- For maths.
local rnd,Seed,rand,randi,normal,merges   
--  For  files.
local csv                  
--  Code  called at start-up.
local run,main        


--------------------------------------------------
-- ## Row
-- Store one example.
function Row:new(a,rows)
  return Obj.new(self,"Row",{cells=a, _rows=rows}) end

function Row:lt(other,        n,s1,s2,goals)
  cols = _rows.cols.y
  s1,s2,n = 0,0,#goals
  for _,col in pairs(goals) do
    a,b = self.cells[col.at], other.cells[col.at]
    a,b = col:norm(a), col:norm(b)
    s1  = s1 - math.e^(col.w*(a-b)/n)
    s2  = s2 - math.e^(col.w*(b-a)/n) end
  return s1/n > s2/n end

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

-- Store many  examples, summarized in columns.
function Rows:new(inits,     x)
  x= Obj.new(self,"Rows",{
      rows={}, keep=true,
      cols={all={},names={},x={},y={}}})
  for _,row in pairs(inits or {}) do x:add(row) end  
  return x end

-- clone a copy 
function  Rows:clone(inits,    t)
  t = Rows:new({self.cols.names})
  for _,x in pairs(inits or {}) do 
    t:add(x) end
  return t end

-- Read from a file
function Rows:read(f) 
  for row in csv(f) do self:add(row) end 
  return self end

-- If this is row1, create the header. Else, add new data.
function Rows:add(a)
   a = (a._name and a._name=="Row" and a.cells) or a
   if   #(self.cols.names) > 0 
   then return self:data(a) 
   else return self:header(a) end end

-- Update the column summaries. Maybe  keep the new row.
function Rows:data(a,    row)
  for _,col in pairs(self.cols.all) do 
     a[col.at]=col:add(a[col.at]) end
  if self.keep then
    row = Row:new(a,self) 
    self.rows[ 1 + #self.rows] = Row:new(a,self) end 
  return row end

-- Read the magic symbols, make the appropriate columns,
-- store them in the right  places.
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

-- stats, number classes ---------------------------------
local z=1E-32

function Err:new(data,rx)
  return Obj.new(self,"Err",{
    data = data or "data", rx= rx or "rx", _mre=Num()}) end 

function Err:add(want,got) 
  mre:add(math.abs(want-got)/want) end

function Err:mre() 
  return self._mre:mid() end

-- stats, discrete classes ---------------------------------
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

-- Rank ------------------------------------------------------
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
-- ## Functions

-- ### List Functions
function eq(a,b,    ta,tb)
   ta, tb = type(a), type(b)
   if ta ~= tb                              then return false end
   if ta ~= 'table' and tb ~= 'table'       then return a == b end
   for k,v in pairs(a) do if not eq(v,b[k]) then return false end end
   for k,v in pairs(b) do if not eq(v,a[k]) then return false end end
   return true
end

-- shuffles, in place the table `a`
function shuffle(a,n,    j)
  for i = #a, 2, -1 do
    j = randi(1,i)
    a[i], a[j] = a[j], a[i] end
  return n and top(a, n) or a end

-- pull one items from `t`
function sample(t) 
  return t[randi(1,#t)] end

-- samples with replacement, from list `t`.
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
  for k,_ in pairs(t) do keys[1 + #keys] = k end
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

-- ### Meta Functions
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

-- ### String functions
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

-- ### Maths Functions
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

-- ### File functions
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

-- ###  Start-up functions
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

-- `cli()` creates  command line flags by mapping `config` to `:flags`
-- or `:options` calls to `argparse`.  By convention, boolean options
-- default  to false and their  command-line  flag flips them to `true`.
-- Also, if reading  a numeric option from  command line, remember to
-- coerce it to a number.
local function cli(about,       arg,b4)
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
-- ## Unit Tests

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
 
-- ```
-- db |    rx |   num |     a |     b |     c |     d |  acc |  pre |   pd |   pf |    f |    g | class
-- ---- |  ---- |  ---- |  ---- |  ---- |  ---- |  ---- | ---- | ---- | ---- | ---- | ---- | ---- |-----
-- data |    rx |    14 |    11 |       |     1 |     2 | 0.93 | 0.67 | 1.00 | 0.08 | 0.80 | 0.96 | no
-- data |    rx |    14 |     8 |       |       |     6 | 0.93 | 1.00 | 1.00 | 0.00 | 1.00 | 1.00 | yes
-- data |    rx |    14 |     8 |     1 |       |     5 | 0.93 | 1.00 | 0.83 | 0.00 | 0.91 | 0.91 | maybe
-- ```

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


-- -- do it stochastic. pick variants at random
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
-- ## Start-up
about = require "about"

main( cli(about))
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
os.exit(fails) 
