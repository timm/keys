#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Storage for rows, summarized in columns.    
-- Tim Menzies, (c) 2021, MIT     

-- ---------------------------------------------

local lib  = require "lib"
local Skip = require "skip"
local Sym  = require "sym"
local Num  = require "num"
local goalp,klassp,nump,weight,skip,what,col,add

-- ## Identify column types

-- Is `s` the name of a goal column?
function goalp(s) return s:find("+") or s:find("-") or s:find("!")  end

-- Is `s` the name of a class column?
function klassp(s) return s:find("!") end

-- Is `s` the name of a numeric column?
function nump(s) return s:sub(1,1):match("[A-Z]") end

-- What is the weight of a column called `s`?
function weight(s) return s:find("-") and -1 or 1 end

-- Should I skip this row, column?
function skip(s) return s:find("?") end

-- What kind of column should be created from `s`?
function what(s) return skip(s) and Skip or (nump(s) and Num or Sym) end

-- -----------------------------------
-- ## Generics (for all columns).

-- Unless skipping, increment `n` and add `x`. Note that the call
-- `col:add(x)` is polymorphic so this function can be used to add 
-- to any kind of column.
function add(col,x) if x~="?" then col.n = col.n+1; col:add(x) end end

-- -----------------------------------
-- ## class Rows
-- Holder for rows, summarized in columns.

local Rows= {rows={}, txt="", cols={}, xs={}, ys={}}

-- Throw in a new row. If this is the first row, use it to make column headers.
-- Else, update the column headers then add a new row.
function Rows:add(t) 
  t = t._isa==Row and t.calls or t
  if   #self.cols==0 
  then self.cols = self:newCols(t) 
  else self.rows[#self.rows+1] = self:newRow(t) end end

-- Before adding a row, update the column headers.
function Rows:newRow(t)
  for at,v in pairs(t) do add(self.cols[at], v) end 
  return t end

-- Using the text of the row, determine what columns
-- are needed for this data. Just for  convenience,
-- sometimes we store a column in several places. E.g.
-- all columns are stored in `out` but (e.g.) the independent
-- variables also get added to `self.xs`.
function Rows:newCols(t, out)
  out={}
  for at,txt in pairs(t) do 
    local new,where
    new   = lib.isa(what(txt), {at=at, txt=txt, w=weight(txt)}) 
    where = goalp(txt) and self.ys or self.xs
    if klassp(txt) then self.klass= new end
    where[#where+1] = new
    out[#out + 1] = new end 
  return out end

-- -----------------------------------
-- And finally...

return {add=add, Sym=Sym, Num=Num,
        Row=Row, Rows=Rows}
