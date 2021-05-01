#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Nonparametric stats
-- (c) Tim Menzies, 2021   

-- -----------------------------
local Rx={_is="Rx",all={},ok=false,sum=0,n=0}

function Rx:add(x) 
  self.sum = self.sum + x
  self.n   = self.n + 1
  self.mu  = self.sum / self.n
  self.all[#self.all+1] = x
  self.ok = false end

function Rx:sub(x) 
  self.sum = self.sum - x
  self.n   = self.n - 1
  self.mu  = self.sum / self.n end

function sk(rxs)
  local all = isa(Rx)
  table.sort(rxs,function (x,y) return x.mu < y.mu end)
  for _,rx in pairs(rxs) do
    for _,x in pairs(rx.all) do all:add(x) end end 
  local mu,n = all.mu, all.n
  local best=10^32
  for _,rx in pairs(rx) do
    
