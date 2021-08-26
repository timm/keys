-- ## copy(t:table)
-- Return a deep copy of `t`.
local function copy(t,      seen,      res)
  seen = seen or {}
  if type(t) ~= 'table' then return t end
  if seen[t] then return seen[t] end
  res = setmetatable({}, getmetatable(t))
  seen[t] = res
  for k,v in pairs(t) do res[copy(k,seen)]=copy(v,seen) end
  return res end

-- ## show(t:table)
-- Return a string for of key:value  in `t`. 
local function show(t,    s,sep,keys)
  sep, keys, s = "", {}, (t._name or "").."{"
  for k,_ in pairs(t) do 
    if "_" ~= k:sub(1,1) then keys[1+#keys]=k end end
  table.sort(keys)
  for _,k in pairs(keys) do
    s = s..sep..k..":"..tostring(t[k])
    sep=" " end
  return s..'}' end

return {show=show, kopy=kopy}
