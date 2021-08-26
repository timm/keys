-- ## Column types
local isKlass, isGoal, isNum, isWeight, isSkip

function isKlass(s)  return s:find("!") end
function isGoal(s)   return s:find("+") or s:find("-") or isKlass(s) end
function isNum(s)    return s:sub(1,1):match("[A-Z]") end
function isWeight(s) return s:find("-") and -1 or 1 end
function isSkip(s)   return s:find("?") end

-- ## add(x:any, y:col)
-- Add `x` to `y`.
local function add(x, y)
  if x ~= "?" then
    self.n = self.n + 1
    if self.some then self.some:add(x) end
    y:add1(x) end
  return x end

-- ## adds(lst:table, ?y:col)
-- Return a summary of  `lst`, summarized into `y'.
local function adds(lst, y)
  for _,x in pairs(lst) do add(x,y) end
  return y end

return {add=add, adds=adds,
        isKlass=isKlass, isGoal=isGoal, isNum=isNum,
        isWeight=isWeight, isSkip=isSkip}
