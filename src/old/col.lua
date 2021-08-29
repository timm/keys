-- **Column types**
local isKlass, isGoal, isNum, isWeight, isSkip

function isKlass(s)  return s:find("!") end
function isGoal(s)   return s:find("+") or s:find("-") or isKlass(s) end
function isNum(s)    return s:sub(1,1):match("[A-Z]") end
function isSkip(s)   return s:find("?") end

-- **add(x : any, y : col) : x**   
-- Add `x` to `y`.
local function add(x, y)
  if x ~= "?" then
    y.n = y.n + 1
    if y.some then y.some:add(x) end
    y:add1(x) end
  return x end

-- **adds(lst : table, ?y : col) : y**  
-- Return a summary of  `lst`, summarized into `y`.
local function adds(lst, y)
  for _,x in pairs(lst) do add(x,y) end
  return y end

-- ----------------
return {
  add = add, 
  adds = adds,
  isGoal = isGoal, 
  isKlass = isKlass, 
  isNum = isNum,
  isSkip = isSkip,
  isWeight = isWeight 
}
