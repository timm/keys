#!/usr/bin/env lua
--vim: filetype=lua ts=2 sw=2 sts=2 et :

--  ## Column (abstact class)

local isKlass, isGoal, isNum, isWeight, isSkip,adds, merged

-- This code reads tables of data where line1 shows the name
-- for each column. For example:
--
--     name?, Age, Shoesize, Job,  Salary+ YearsOnJob-
--     tim,   21,  10,       prof, 100,     100
--     jane,  60,  10,       hod,  1000,    10
--     ...    ..   ..        ..    ..       ..
--
-- Note that the row1 names have magic symbols.
-- Numerics start with uppercase. Goals to be minimize or
-- maximized end with `-` and `+` (respectively). Columns
-- to be ignored contain `?`. Columns usually have a `weight`
-- of "1" unless we are minimizing them in which case that is "-1".
--

-- ## function add(t:_table_, ?col:_Num|Sym_)
-- The following functions work for all columns.
-- `adds()` lets you create one or update a `col`umn with a list of
-- column `a`  (and if creating, then it guesses column type from the
-- first entry).
function adds(t,col) 
  col = col or (type(t[1])=="number" and Num or Sym):new()
  for _,x in pairs(t) do col:add(x) end 
  return col end

-- ## function Column header
function isKlass(s)  return s:find("!") end
function isGoal(s)   return s:find("+") or s:find("-") or isKlass(s) end
function isNum(s)    return s:sub(1,1):match("[A-Z]") end
function isWeight(s) return s:find("-") and -1 or 1 end
function isSkip(s)   return s:find("?") end

-- ## function merged(i:_Num|Sym_, j:_Num|Sym_)
-- Returns a merged column if the expected value of the
-- variance of the merge is better (less) than the variance of the parts.
function merged(i,j,         k)
  k= i:merge(j)
  if k:var() < (i.n*i:var() + j.n*j:var()) / (i.n + j.n) then 
    return k end end

-- -----------------------------------------
-- Return:
return {isKlass=isKlass, isGoal=isGoal, isNum=isNum,
        isWeight=isWeight, isSkip=isSkip, adds=adds,
        merged=merged}
