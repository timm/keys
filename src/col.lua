#!/usr/bin/env lua
--vim: filetype=lua ts=2 sw=2 sts=2 et :

--  ## Column (abstact class)

local klassp, goalp, numo, weight, skipp,adds, merged

function klassp(s) return s:find("!") end
function goalp(s)  return s:find("+") or s:find("-") or klassp(s) end
function nump(s)   return s:sub(1,1):match("[A-Z]") end
function weight(s) return s:find("-") and -1 or 1 end
function skipp(s)  return s:find("?") end

-- The following functions work for all columns.
--  `adds()` lets you create one or update a `col`umn with a list of
-- column `a`  (and if creating, then it guesses column type from the
-- first entry).
function adds(t,col) 
  col = col or (type(t[1])=="number" and Num or Sym):new()
  for _,x in pairs(t) do col:add(x) end 
  return col end

-- Finally, `merged()` checks if life is simpler if we combine two columns.
function merged(i,j,         k)
  k= i:merge(j)
  if k:var() < (i.n*i:var() + j.n*j:var()) / (i.n + j.n) then 
    return k end end

return {klassp=klassp, goalp=goalp, nump=nump,
        weight=weight, skipp=skipp}
