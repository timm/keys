-- <img width=75 src="https://github.com/timm/keys/raw/main/etc/img/learn.png"> <hr>
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
  synopois= "summarize data",
  author  = "Tim Menzies, timm@ieee.org",
  license = "MIT",
  year    = 2020}

-- ## Objects 
local Lib  = require "lib"
local Tbl  = require "tbl"
local Div2 = {ako="Div2", mid=0,lefts={}, rights={},kids={}}

---------------------
-- ## Shortcuts
local isa=Lib.isa
local cell=Tbl.cell

---------------------
-- ## Cluster

function Div2.new(t,out,rows,min,lvl)
   out  = out or {} 
   rows = rows  or t.rows 
   min  = min   or (#rows)^0.5
   lvl  = lvl   or 0
   local i = isa(Div2)
   i:split(t,out,rows,min,lvl)
   return i,out end

function Div2:split(t,out,rows,min,lvl)
  if #rows < min * 2 then 
    out[#out+1] = rows
  else
    print(string.rep("|.. ",lvl)..#rows)
    local one = Lib.any(rows)
    self.left = t:far(one, rows)
    self.right, self.c = t:far(self.left, rows)
    for _,row in pairs(rows) do
      local a = t:dist(row, self.left)
      local b = t:dist(row, self.right)
      local x = (a^2 + self.c^2 - b^2) / (2*self.c)
      x = math.max(0, math.min(self.c, x))
      row.tmp = x
    end
    table.sort(rows, function(a,b) return a.tmp < b.tmp end)
    self.mid = rows[#rows //2].tmp
    -- print(rows[1].tmp, self.mid, rows[#rows].tmp)
    for _,row in pairs(rows) do
      local what = row.tmp <= self.mid and self.lefts or self.rights
      what[#what+1] = row 
    end
    --print(#rows, #self.lefts, #self.rights)
    if  #self.lefts < #rows and #self.rights < #rows then
      self.kids[1]= Div2.new(t,out,self.lefts, min,lvl+1)
      self.kids[2]= Div2.new(t,out,self.rights,min,lvl+1) end end end

-- And finally...
return {Div2=Div2}
