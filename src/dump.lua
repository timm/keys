--vim: filetype=lua ts=2 sw=2 sts=2 et :

-- # Dump tables to string
-- Note for Python  programmers:
-- To get pretty-print for objects, inherit from ``o``:
--
--    class o(object):
--      def __init__(i, **k): i.__dict__.update(**k)
--      def __repr__(i):
--        return i.__class__.__name__ + str(
--          {k: v for k, v in i.__dict__.items() if k[0] != "_"})
local dump,rump,pump

-- ## pump
-- Print  string of table.   
-- Params:
-- - t:table
function pump(t) print(dump(t)) end

-- ## dump
-- Converts a table  to string (without  recursion into values).   
-- Params:
-- - t:_table_
function dump(t,     sep,s,k,keys)
  if (#t > 0) then
    return table.concat(t,",") end
  sep, s = "", (t._name or "") .."{"
  keys = {}
  for k in pairs(t) do keys[#keys+1] = k end
  table.sort(keys)
  for _,k in pairs(keys) do
    if k:sub(1,1) ~= "_" then
      s=s .. sep .. tostring(k).."="..tostring(t[k])
      sep=", " end end 
  return s.."}" end

-- ## rump
-- Print string version of a value (with
-- recursion into values.    
-- Params:
-- - t:_table_
-- - pre:_string_. Prefix string (show before each entry).
function rump(t,pre,    indent,fmt)
  pre, indent = pre or "", indent or 0
  if indent < 10 then
    for k, v in pairs(t or {}) do
      if not (type(k)=='string' and k:match("^_")) then
        fmt= pre..string.rep("|  ",indent)..tostring(k)..": "
        if type(v) == "table" then
          print(fmt)
          rump(v, pre, indent+1)
        else
          print(fmt .. tostring(v)) end end end end end

-- ## Returns
return {dump=dump, rump=rump, pump=pump}


