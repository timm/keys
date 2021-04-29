#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Storage for rows, summarized in columns.    
-- Tim Menzies, (c) 2021, MIT     
-- [index](index.html)

-- ---------------------------------------------

local lib  = require "lib"
local Skip = require "skip"
local Sym  = require "sym"
local Num  = require "num"

local goalp,klassp,nump,weight,skip,what,col,add

-- ## Functions

-- Is `s` the name of a goal column?
function goalp(s, c) return s:find("+") or s:find("-") or s:find("!")  end

-- Is `s` the name of a class column?
function klassp(s, c) return s:find("!") end

-- Is `s` the name of a numeric column?
function nump(s) return s:sub(1,1):match("[A-Z]") end

-- What is the weight of a column called `s`?
function weight(s) return s:find("-") and -1 or 1 end

-- Should I skip this row, column?
function skip(s) return s:find("?") end

-- What kind of column should be created from `s`?
function what(s) return skip(s) and Skip or (nump(s) and Num or Sym) end

-- Make a new column, and if `inits` is supplied, then  load it data.
function col(at,txt, inits)
  local new = lib.isa(what(txt), {at=at, txt=txt, w=weight(txt)}) 
  for _,y in pairs(inits or {}) do new:add(y) end
  return new end

-- Unless skipping, increment `n` and add `x`.
function add(col,x) if x~="?" then col.n = col.n+1; col:add(x) end end

-- -----------------------------------
-- ## Rows
-- Holder for rows, summarized in columns.

local Rows= {rows={}, txt="", cols={}, xs={}, ys={}}

function Rows:add(t) 
  t = t._isa==Row and t.calls or t
  if #self.cols>0 then
    for at,v in pairs(t) do add(self.cols[at], v) end 
    self.rows[#self.rows+1] = t
  else
    for at,v in pairs(t) do 
      local new,where
      new  = col(at,v) 
      where = goalp(v) and self.ys or self.xs
      if klassp(v) then self.klass= new end
      where[#where+1] = new
      self.cols[#self.cols + 1] = new end end end

-- -----------------------------------
-- And finally...

return {add=add, Sym=Sym, Num=Num,
        Row=Row, Rows=Rows}
