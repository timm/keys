#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 et :
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

--- Handing data detais

local MY=require "my"
local Meta,Tab,Obj,Sys  = require "lib"

----------------------------------------------------
--- Sym
-- @type Sym
local Sym={}

function Num:Sym(at,s)
  return Obj.new("self","NUM", {at=n,txt=s,n=0}) end

----------------------------------------------------
--- Num
-- @type Num
local Num={}

function Num:new(at,s)
  return Obj.new("self","NUM",
    {at=n,txt=s,n=0,w=s:match("-") and -1 or 1, _all={}, ok=false}) end

function Num:add1(x,_)
  if x~="?" then
    self.n = self.n + 1
    x = tonumber(x)
    self._all[1+ #self._all] = x
    self.ok = true end
  return x end

function Num:all()
  if not self.ok then table.sort(self._all); self.ok=true end
  return self._all end

function Num:sd() return (self:_per(.9)-self._per(.1))/2.56 end
function Num:mid() return self:_per(.5) end
function Num:_per(p) 
  local a=self:all(); return a[math.floor(p*#a)] end
function Num:norm(x) 
  local a=self:all(); return (x -a[1])/(a[#a]-a[1]+1E-32) end

-- --------------------------------------------
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
