-- **csv(file : str) : table**    
-- Iterator. Returns rows in a csv files. Converts 
-- strings to numbers if appropriate. 
local function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      tmp = tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      t   = {}
      for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if   #t > 0 
      then for j,x in pairs(t) do t[j]=tonumber(x) or x end;
           return t 
      end
    else io.close(stream) end end end

return {csv=csv}
