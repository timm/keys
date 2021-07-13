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

USAGE: ./keys0.lua [OPTIONS]

OPTIONS:

  -h            print help
  -data FILE    read data from FILE
  -goal STR     one of optimizer, monitor, explode
  +verbose      enable verbose mode
]] 

local MY={data   = "../data/auto93.csv"
         ,todo   = "hi"
         ,k      = 2
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
    goal   = t.goal or goal.optimize,
    init   = t.init or nil}) 
  if init then new:add(init) end 
  return new end

--- If new  `(attr,val)` pair saturates `attr`, then delete `attr`
function Rule:add(pair)
  local attr,val             = pair[1],pair[2]
  self._score          = nil
  self.has[attr]       = self.has[attr] or {}
  self.has[attr][val]  = true 
  if   #self.has[attr] == #self.tbl.attrs[attr] 
  then self.has[attr]  = nil end end

--- If the merge  of self and other is  the same as either, return nil.
function Rule:merge(other)
  out = Rule:new{counts=self.counts, goal=self.goal, want=self.want}
  for _,rule in pairs{self, other}  do
    for attr,vals in pairs(rule.has) do
      for _,val in pairs(vals) do  out:add{attr,val} end end end
  if out.has then
    if not Lib.tab.eq(out.has, self.has) then
      if  not Lib.tab.eq(out.has, other.has) then
         return out end end end end  
        
----------------------------------------------------
--- File
-- @section File

--- For discretized data, count the classes, attributes, attributes in classes.
function Lib.file.count(src)
  local t,inc,klass,row
  t   = {rows={},klasses={}, attrs={},avs={},freqs={}}
  inc = Lib.tab.incs
  for lst in src do 
    if   t.names 
    then row = Row:new(lst)
         t.rows[1 + #t.rows] = row
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
