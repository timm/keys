-- **color(s: str, arg1, arg2. ...):str**   
local function color(s,...)
  local all = {red=31, green=32, yellow=33, purple=34}
  print('\27[1m\27['.. all[s] ..'m'..string.format(...)..'\27[0m') end

-- **sfmt(fmt :string, ?arg1 :any, ?arg2 :any, ...)**  
-- format a string
local function sfmt(...) return string.format(...) end

-- **fmt(fmt :string, ?arg1 :any, ?arg2 :any, ...)**  
-- format and print t a string.
local function fmt( ...) io.write(sfmt(...)) end

return {color=color, fmt=fm, sfmt=sfmt}
