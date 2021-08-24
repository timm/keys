--vim: filetype=lua ts=2 sw=2 sts=2 et :

local function helpString(fig,   h)
  h = {}
  for k,v2 in pairs(fig.options) do
    if   v2[1]  == false 
    then h[1+#h] = string.format("  -%-10s %-10s %s",k,"", v2[2]) 
    else h[1+#h] = string.format("  -%-10s %-10s %s (:default %s)",
                                 k, k:sub(1,#k), v2[2], v2[1]) end end
  table.sort(h)
  return "usage: "..fig.usage.." [OPTIONS]\n\n"..fig.synopsis.."\n"..
         "OPTIONS:\n".. table.concat(h,"\n") end

--- function cli(t:_table_, args:_table_)
-- Update slots in a  copy of `t` using values from `args`.
local function cli(fig,args,       out,b4,f)
  out = {}
  for k,v2 in pairs(fig.options) do out[k]=v2[1]  end
  for i = 1,#args do
    if   args[i] == "-h" 
    then print(helpString(fig)) 
    else f  = args[i]:sub(2,#t[i])
         b4 = fig.options[f] 
         if     b4 and b4[1] == false 
         then   out[f] = true
         elseif b4 
         then   out[f] = tonumber(arg[i+1]) or arg[i+1] end end end
  return out end

return cli
