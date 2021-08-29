-- **color(s: str, arg1, arg2. ...)**   
local function color(s,...)
  local all = {red=31, green=32, yellow=33, purple=34}
  print('\27[1m\27['.. all[s] ..'m'..string.format(...)..'\27[0m') end

return {color=color}
