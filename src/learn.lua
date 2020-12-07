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

-- XXX 
function Div2(t, min, leafs, rows, lvl)
  lvl      = lvl or 0
  local i  = i or {}
  rows     = rows or t.rows
  min      = min or (#rows)^0.5
  i        = {mid=0, leafs = leafs}
  i.a, i.b = t:far2(rows)
  i.c      = t:dist(i.a, i.b)
  for _,row in pairs(rows) do
    a = t:dist(row,ra)
    b = t:dist(row,rb)
    x = (a^2 + c^2 - b*2) / (2*c)
    x = math.max(0, math.min(1, x))
    row.tmp = x
    i.mid = i.mid + x/2
  end
  i.as,i.bs = {},{}
  for _,row in paris(rows) do
    local what = row.tmp < i.mid and i.as or i.bs
    what[#what+1] = row 
  end
  if #rows < min * 2 then 
    leafs[#leafs+1] = rows
  else
    if #i.as < #rows and #i.bs < #rows then
      i.left  = Div2(t, min, leafs, lt, lvl+1)
      i.right = Div2(t, min, leafs, gt, lvl+1) end end
  return i end

-- And finally...
return {Cluster=Cluster}
