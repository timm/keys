-- <img width=75 src="https://github.com/timm/keys/raw/main/etc/img/tbl.png"> <hr>
-- <a href="http://github.com/timm/keys"><img src="https://github.blog/wp-content/uploads/2008/12/forkme_left_red_aa0000.png?resize=149%2C149" align=left></a>  
-- "Keys = cluster, discretize, elites, contrast"    
-- [![DOI](https://zenodo.org/badge/318809834.svg)](https://zenodo.org/badge/latestdoi/318809834)  
-- ![](https://img.shields.io/badge/platform-osx%20,%20linux-orange)    
-- ![](https://img.shields.io/badge/language-lua,bash-blue)  
-- ![](https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet)  
-- [![Build Status](https://travis-ci.com/timm/keys.svg?branch=main)](https://travis-ci.com/timm/keys)   
-- ![](https://img.shields.io/badge/license-mit-lightgrey)  
-- [home](http://menzies.us/keys)         :: [lib](http://menzies.us/keys/lib.html) ::
-- [cols](http://menzies.us/keys/cols.html) :: [tbl](http://menzies.us/keys/tbl.html)   
--------------------
local Of  = {
  synopois= "tables with rows, summarized in column headers",
  author  = "Tim Menzies, timm@ieee.org",
  license = "MIT",
  year    = 2020,
  ch      = {sym="_"},
  tbl     = {samples=128},
  row     = {p=2, cols="ys"}}

-- ## Objects 
local Lib            = require "lib"
local Cols           = require "cols"
local Col,Num,Sym,Some = Cols.Col, Cols.Num, Cols.Sym, Cols.Some
local Row            = {ako="Row",  cells={}, bins={}}
local Tbl            = {ako="Tbl",  header={}, rows={},  cols={},
                        ys={},      xs={},    dist={}}
local TwoDiv         = {ako="BiDev"}

---------------------
-- ## Shortcuts
local isa=Lib.isa
local function cell(x) return not(type(x)=="string" and x=="?") end

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
    self.header=t
    for j,x in pairs(t) do self.cols[j] = Col.factory(j,x,self) end 
  else
    self.rows[(#self.rows)+1] = Row.new(t,self) end end

function Tbl:cloneCells(rows)
  local i = Tbl:new()
  i:add(self.header)
  for _,row in pairs(rows or {}) do self:add(row.cells) end 
  return i end

function Tbl:cloneBins(rows)
  local i = Tbl:new()
  local top=Lib.copy(self.header)
  for j,col in pairs(self.xs) do 
     if col.ako == "Num" then top[j] ="_" .. col.txt end end
  i:add(top)
  for _,row in pairs(rows or {}) do i:add(row.bins) end 
  return i end
  
function Tbl:mid()
  local t={}
  for _,col in self.cols do t[col.pos] = col:mid() end
  return t end

-- Read from files
function Tbl.read(f,    t) 
  t=Tbl.new()
  for row in Lib.csv(f) do t:add(row) end
  return t end

-- Unsupervised discretization 
function Tbl:bins(samples,d,n)
  samples = samples or Of.tbl.samples
  for _,col in pairs(self.xs) do
    if col.ako == "Num" then
      local pos, some = col.pos, isa(Some,{max=samples})
      for _,row in pairs(self.rows) do 
        some:add(row.cells[pos]) end
      local bins = some:bins(d, n)
      for _,row in pairs(self.rows) do
        row.bins[pos] = some:bin(row.cells[pos], bins) end end end end

function Tbl:dist(row1,row2) 
  return row1:dist(row2, self[Of.row.cols]) end

-- Find a sample of things around `row`.
function Tbl:around(row, rows)
  rows= rows or self.rows
  local t = {}
  for j = 1,math.min(100,#rows) do
    local other = Lib.any(rows)
    t[#t+1] = {d = self:dist(row,other),
               row = other} end
  table.sort(t,  function(x,y) return x.d < y.d end)
  return t end

-- Return a point about 90% difference.
function Tbl:far(row,rows) 
  rows = rows or self.rows
  local t = self:around(row,rows)
  local x = t[(.9*#t)//1]
  return x.row, x.d end

------
-- And finally...
return {cell=cell, Tbl=Tbl,Row=Row}
