-- <img width=75 src="https://cdn0.iconfinder.com/data/icons/data-charts/110/TableDataGridThickLines-512.png">   <br>
-- <a href="http://github.com/timm/keys"><img src="https://github.blog/wp-content/uploads/2008/12/forkme_left_red_aa0000.png?resize=149%2C149" align=left></a>  
-- "Keys = cluster, discretize, elites, contrast"    
-- ![](https://img.shields.io/badge/platform-osx%20,%20linux-orange?style=flat-square)  
-- ![](https://img.shields.io/badge/language-lua,bash-blue?style=flat-square)  
-- ![](https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet?style=flat-square)  
-- ![](https://img.shields.io/badge/license-mit-green?style=flat-square)  
-- [home](http://menzies.us/keys)         :: [lib](http://menzies.us/keys/lib.html) ::
-- [col](http://menzies.us/keys/col.html) :: [tbl](http://menzies.us/keys/tbl.html)   
--------------------
local Of  = {
  synopois= "tables with rows, summarized in column headers",
  author  = "Tim Menzies, timm@ieee.org",
  license = "MIT",
  year    = 2020,
  tbl     = {samples=128},
  row     = {p=2,cols="ys"}}

-- ## Objects 
local Row  = {ako="Row",  cells={}, bins={}}
local Tbl  = {ako="Tbl",  rows={}, cols={},ys={},xs={}, dist={}}

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
    for j,x in pairs(t) do Col.factory(j,x,self) end 
  else
    self.rows[(#self.rows)+1] = Row.new(t,self) end end
      
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

------
-- And finally...
return {Tbl=Tbl,Row=Row}
