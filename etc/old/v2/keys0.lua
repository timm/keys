#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

--- Contrast set learning.

--- @usage
local usage = [[
keys0 : Contrast set learning
(c) 2021 Tim Menzies timm@ieee.org, unlicense.org

The difference between things is often shortert
to describe than the things themselves.

USAGE: ./eg.lua [OPTIONS] [-x ACTION]

OPTIONS:

  -h            print help
  -data FILE    read data from FILE
  -goal STR     one of optimizer, monitor, explode
  +verbose      enable verbose mode
  -x STR        run action 
]] 

local MY={data   = "../data/auto93.csv"
         ,x      = "hi"
         ,k      = 2
         ,m      = 1
         ,top    = 10
         ,verbose= false}

local Lib=require("lib")

----------------------------------------------------
--- Row
-- @type Row
local Row={}

--- Numbers have standard deviation.
function Row:new(cells) 
  return Lib.obj.new(self,"Row",{cells=cells, id=Lib.meta.id()}) end

----------------------------------------------------
--- Rule
-- @type Rule
local Rule={}

local goal={}
function goal.optimize(b,r) return b^2 / (b+r)  end
function goal.monitor(b,r) return r^2 / (b+r)  end
function goal.explore(b,r) return 1  / (b+r) end

--- Numbers have standard deviation.
function Rule:new(t,new) 
  local new= Obj.new(self,"Rule",{
    has    = {},
    _score = nil,
    counts = t.counts,
    want   = t.want or self.want,
    goal   = t.goal or goal.optimize})
  if init then new:add(init or {}) end 
  return new end

--- If new  `(attr,val)` pair saturates `attr`, then delete `attr`
function Rule:add(pair)
  local attr,lo,hi     = pair[1], pair[2][1], pair[2][2]
  self._score          = nil
  self.has[attr]       = self.has[attr] or {}
  self.has[attr][val]  = true 
  if   #self.has[attr] == #self.tbl.attrs[attr] 
  then self.has[attr]  = nil end end

--- If the merge  of `self` and `other` is the same as either, return nil.
function Rule:merge(other)
  local out = Rule:new{counts=self.counts, goal=self.goal, want=self.want}
  local eq  = Lib.tag.eg
  for _,rule in pairs{self, other}  do
    for attr,vals in pairs(rule.has) do
      for _,val in pairs(vals) do  
        out:add{attr,val} end end end
  if out.has then
    if not eq(out.has, self.has) then
      if  not eq(out.has, other.has) then
         return out end end end end  

function Rule:show()
  local sort,fmt = Lib.meta.sort, string.format
  local show,merge,vals
  -- -- --
  function show(x) 
    return x[1]==x[2] and fmt("%",x[1]) or fmt("[%s..%s]",x[1],x[2]) end 
  -- -- --
  function merge(pairs,    j,tmp) 
    j,tmp = 1,{}
    while j <=#pairs do
      a=pairs[j]
      if j <#pairs then
        b = pairs[j+1]
        if a[2]==b[1] then j=j+1; a={a[1],b[2]} end end
      tmp[1 + #tmp] = a
      j = j + 1
    return tmp end end
  -- -- --
  function vals(x,       u) 
    u = {}
    for _,x in pairs(self.has[x]) do u[1 + #u] = x end
    return sort(u, function(a,b) return a[1]<=b[1] end) end
  -- -- --
  function ors(t,     s,sep)
    s,z = "(",""
    for _,x in pairs(merge(vals(t))) do s=s..z..show(x);z=" or "end
    return s..")" end
  -- -- --
  local s,z,u = "","",{}
  for x,_ in pairs(self.has) do u[1 + #u] = x end
  for _,x in pairs(sort(u)) do s=s..z.."="..ors(x);z=" and "end
  return s end

function Rule:like(kl,my)
  local has    = Lib.meta.has
  local fs,kln = {}, has(self.counts.klasses,{kl})
  local prior  = (kln + my.k) / (self.counts.n + my.m)
  local all    = {}
  for pos,vals in pairs(self.has) do
    for val,_ in pairs(vals) do
      local inc = has(self.counts, {kl,pos,val,val}) 
      all[kl]   = inc + (all[kl] or 0) end end
  local like = prior
  for _,one in pairs(all) do
    like = like * (one + the.m * prior) / (kln + the.m) end
  return like end

----------------------------------------------------
--- File
-- @section File

--- For discretized data, count the classes, attributes, attributes in classes.
function Lib.file.count(src)
  local t,inc,klass,row
  t   = {n=0, klasses={}, attrs={},avs={},freqs={}}
  inc = Lib.tab.incs
  for lst in src do 
    if   t.names 
    then row = Row:new(lst)
         t.n = t.n + 1
         klass = lst[t.klass]
         inc(t.klasses, { klass } )
         for pos,val in pairs(lst) do
           if val ~= "?" then
             inc(t.attrs,           {pos,val})
             inc(t.avs,         {pos,val,val})
             inc(t.freqs, {klass,pos,val,val}) end end
    else t.names = lst
         t.klass = #lst end end 
  return t end

-------------------------------------------------
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
return {usage=usage, my=MY, row=Row, rule=Rule}
