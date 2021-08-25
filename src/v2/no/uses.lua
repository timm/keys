-- vim: ts=2 sw=2 sts=2 et :

local used={}
local function uses(f,      reads)
  function reads(f,    c,t)
    print("-- ",f)
    t, c, f = {}, true, io.input(f)
    for x in f:lines() do
      if #x >=6 and x:sub(1,6)=="```lua" then c,x=false,"--"..x end
      if #x >=3 and x:sub(1,6)=="```"    then c  =true end
      t[1+#t] = (c and "-- " or "") .. x end
    f:close() 
    return table.concat(t,"\n") end
  -----------
  f= f..".md"
  used[f] = used[f] or load(reads(f))()
  return used[f] end

f=uses "cli"
f=uses "cli"
f(10
