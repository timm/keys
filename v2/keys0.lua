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
         ,verbose= false
         ,usage  = usage}

local Eg=require("eg")
local l=require("lib")
local Meta,Tab,File,Obj,Sys=l.meta,l.tab,l.file,l.obj,l.sys

----------------------------------------------------
--- Row
-- @type Row
local Row={}

--- Numbers have standard deviation.
function Row:new(cells) 
  return Obj.new(self,"Row",{cells=cells, id=Meta.id()}) end

----------------------------------------------------
--- Rule
-- @type Rule
local Rule={}

local goal={}
function goal.optimize(b,r) return b^2 / (b+r)  end
function goal.monitor(b,r) return r^2 / (b+r)  end
function goal.explore(b,r) return 1  / (b+r) end

--- Numbers have standard deviation.
function Rule:new(t) 
  return Obj.new(self,"Rule",{
    tbl  = t.tbl,
    want = t.want,
    goal = t.goal or goal.optimize,
    init = t.init or nil}) end

----------------------------------------------------
--- Sample
-- @section Sample
local Sample={}

function Sample.read(src)
   local t   = {rows={},klasses={}, attrs={},avs={},freqs={}}
   local inc = Tab.incs
   for lst in src do
     if   t.names 
     then row = Row:new(lst)
          t.rows[1 + #t.rows] = row
          local klass = lst[t.class]
          inc(t.klasses, { klass } )
          for pos,val in pairs(lst) do
            if val ~= "?" then
              inc(t.attrs,            {val,val})
              inc(t.avs,          {pos,val,val})
              inc(t.freqs,  {klass,pos,val,val}) end end
     else t.names = lst
          t.klass = #lst end end end

-------------------------------------------------
Eg.all(Sys.cli(MY, arg, usage))
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
