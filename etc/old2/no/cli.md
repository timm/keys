# cli
A replacement for `argparse` (in 23 lines of lua).
Configures the command line arguments via the contents of
[about](about.md).

```lua
local cli,cli_help
local function fred(x) print("::",x) end
```

## function cli(t:table, a:table)
Return values from `t.options`, updated with relevant values from `a`.
- `t` has fields `t.usage`, `t.synopsis` and `t.options`.
- `t.options` has key,values of the form `key={default, about}`. 
- If any `defaults` are `false` then using `-key` on  the command  line
  enables `key` to true.
- Otherwise `-key` expects a following argument which this code converts
  to a number or  string, as appropriate.

```lua
function cli(t,a,         help,out,b4,f)
  out = {}
  for k,v2 in pairs(t.options) do out[k]=v2[1] end
  for i = 1,#a do
    if a[i] == "-h" then 
      cli_help(t)
    elseif #a[i] > 1 then
      f  = a[i]:sub(2,#t[i])
      b4 = t.options[f] 
      assert(b4,"unknown flag " .. a[i])
      if b4 then 
        new = (b4[1]==false and true or (tonumber(a[i+1]) or a[i+1])) end
      assert(type(now) == type(b4), a[i+1] .. " not ".. type(b4))
      out[f] = new end end 
  return out end
```
Helper function for `cli`. Generates and prints help string

```lua
function cli_help(t,   h, default,about)
  h = {}
  for k,xy in pairs(t.options) do
    default, about = xy[1], xy[2]
    if   default  == false 
    then h[1+#h] = string.format("  -%-10s %-10s %s",k,"", about)
    else h[1+#h] = string.format("  -%-10s %-10s %s (:default %s)",
                                 k, k:sub(1,#k), about, default) end end
  table.sort(h)
  print("usage: "..t.usage.." [OPTIONS]\n\n"..t.synopsis.."\n"..
         "OPTIONS:\n".. table.concat(h,"\n")) end
```

Returns
```lua
return fred
```
