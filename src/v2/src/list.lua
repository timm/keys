-- copy(t:table)  
-- Return a deep copy of `t`.
local function copy(t,      seen,      res)
  seen = seen or {}
  if type(t) ~= 'table' then return t end
  if seen[t] then return seen[t] end
  res = setmetatable({}, getmetatable(t))
  seen[t] = res
  for k,v in pairs(t) do res[copy(k,seen)]=copy(v,seen) end
  return res end

-- dump(t:table)   
-- Return a string for key:value  in `t`. 
local function dump(t,    s,sep,keys)
  sep, keys, s = "", {}, (t._name or "").."{"
  for k,_ in pairs(t) do 
    if not(type(k)=="string" and "_"==k:sub(1,1)) then
      keys[1+#keys]=k end end
  table.sort(keys)
  for _,k in pairs(keys) do
    s = s..sep..k..":"..tostring(t[k])
    sep=" " end
  return s..'}' end

-- eq(a:any, b:any)  
-- Recursive check if two tables are equal.
local function eq(a,b,    ta,tb)
  ta, tb = type(a), type(b)
  if ta ~= tb                              then return false end
  if ta ~= 'table' and tb ~= 'table'       then return a == b end
  for k,v in pairs(a) do if not eq(v,b[k]) then return false end end
  for k,v in pairs(b) do if not eq(v,a[k]) then return false end end
  return true end

-- pump(t:table)  
-- Print a string for key:value  in `t`. 
local function pump(t) print(dump(t)) end

-- keysort(t:table, ?f:fun)  
-- Sort `t` based on  `f(key)`. 
local function keysort(t, f)
  f = f or (type(f)=="string" and 
            function(z) return z[f] end or
            function(z) return z end)
  table.sort(t, function(x,y) return f(x)<f(y) end)
  return t end

-- sort(t:table, ?f:fun)  
-- Sort `t` based on  `f`. 
local function sort(t, f)
  table.sort(t, t)
  return t end

return {dump=dump, eq=eq, pump=pump, copy=copy, keysort=sort, sort=sort}
