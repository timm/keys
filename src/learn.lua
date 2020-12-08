-- <img width=75 src="https://cdn0.iconfinder.com/data/icons/data-charts/110/TableDataGridThickLines-512.png">   <hr>
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
local Div2 = {ako="Div2"}

---------------------
-- ## Shortcuts
local isa=Lib.isa
local cell=Tbl.cell

---------------------
-- ## Cluster

function Div2.new(t leafs,rows,min,lvl)
   leafs = leafs or {}, 
   rows  = rows  or t.rows, 
   min   = min   or (#t.rows)^0.5)
   lvl   = lvl   or 0
   i = isa(Div2):split(t,leafs,rows,min,lvl)
   return i,leafs

function Div2:split(t, leafs, rows,min,lvl)
  if #rows < min * 2 then 
    leafs[#leafs+1] = rows
  else
    self.left = t:far(any(rows), rows)
    self.right, self.c = t:far(self.left, rows)
    for _,row in pairs(rows) do
      local a = t:dist(row, i.left)
      local b = t:dist(row, i.right)
      local x = (a^2 + c^2 - b*2) / (2*c)
      x = math.max(0, math.min(1, x))
      row.tmp = x
      self.mid = self.mid + x/2
    end
    for _,row in pairs(rows) do
      local what = row.tmp < self.mid and self.lefts or self.rights
      what[#what+1] = row 
    end
      if #self.left < #rows and #self.right < #rows then
        i.left  = Div2(t, leafs, i.lefts, lvl+1)
        i.right = Div2(t, leafs, i.rights, lvl+1) end end end

-- And finally...
return {Cluster=Cluster}
