-- Returns the config options from  [about](about.html),
-- udpated by any command line flags (if any exist).
local about=require"about"

-- **help_string(t : table) : str**     
-- Helper function for `cli. Generates and prints help string
local function help_string(t,   h, default,about)
  h = {}
  for k,xy in pairs(t.options) do
    default, about = xy[1], xy[2]
    if   default  == false 
    then h[1+#h] = string.format("  -%-10s %-10s %s",k,"", about)
    else h[1+#h] = string.format("  -%-10s %-10s %s (:default %s)",
                                 k, k:sub(1,#k), about, default) end end
  table.sort(h)
  return ("usage: "..t.usage.." [OPTIONS]\n\n"..t.synopsis..
         "\n\nOPTIONS:\n".. table.concat(h,"\n")) end

-- **cli(t : table, args : table) : table**   
-- Return values from `t.options`, updated with relevant values from `a`.
-- `t` has fields `t.usage`, `t.synopsis` and `t.options`.
-- `t.options` has key,values of the form `key={default, about}`. 
-- If any `defaults` are `false` then using `-key` on  the command  line
-- enables `key` to true.  Otherwise `-key` expects a following 
-- argument which this code converts to a number or  string, as appropriate. 
local function cli(t,args,            out,b4,f)
  out = {}
  for k,v2 in pairs(t.options) do out[k]=v2[1] end
  for i = 1,#args do
    if args[i] == "-h" then 
      print(help_string(t))
    elseif #args[i] > 1 then
      if "-" == args[1]:sub(1,1) then
        f  = args[i]:sub(2,#t[i])
        b4 = t.options[f] 
        if b4 then
          new = (b4[1]==false and true or (
                tonumber(args[i+1]) or args[i+1])) 
          out[f] = new end end end end
  return out end

-- ---------
-- Return the options, updated by anything on the command-line.
return cli(about,arg)
