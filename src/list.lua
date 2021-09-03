local randi=require("rand").randi


-- **any(t : table) : any**    
-- Return any item for `t`.
local function any(t) return t[ randi(1,#t) ] end

-- **copy(t : table) : table**    
-- Return a deep copy of `t`.
local function copy(t,      seen,      res) 
  seen = seen or {}
  if type(t) ~= 'table' then return t end
  if seen[t] then return seen[t] end
  res = setmetatable({}, getmetatable(t))
  seen[t] = res
  for k,v in pairs(t) do res[copy(k,seen)]=copy(v,seen) end
  return res end

-- **dump(t : table) : str**       
-- Return a string for key:value  in `t`. 
local function dump(t,    s,sep,keys) 
  if #t>0 then return table.concat(t,",") end
  sep, keys, s = "", {}, (t._name or "").."{"
  for k,_ in pairs(t) do 
    if not(type(k)=="string" and "_"==k:sub(1,1)) then
      keys[1+#keys]=k end end
  table.sort(keys)
  for _,k in pairs(keys) do
    s = s..sep..k..":"..tostring(t[k])
    sep=" " end
  return s..'}' end

-- **eq(a : any, b : any) : bool**    
-- Recursive check if two tables are equal.
local function eq(a,b,    ta,tb)
  ta, tb = type(a), type(b)
  if ta ~= tb                              then return false end
  if ta ~= 'table' and tb ~= 'table'       then return a == b end
  for k,v in pairs(a) do if not eq(v,b[k]) then return false end end
  for k,v in pairs(b) do if not eq(v,a[k]) then return false end end
  return true end

-- **pump(t : table)**    
-- Print a string for key:value  in `t`. 
local function pump(t)
  print(dump(t)) end

-- **keysort(t : table, ?key : atom) : table**    
-- Sort `t` based on  `x[key]`. 
local function keysort(t, key)
  table.sort(t, function(x,y) return x[key]<y[key] end)
  return t end

local top

-- **shuffle(t : table, n : number) : table**   
-- Shuffles, in place the table `t`. If `n`
-- supplied, then return the  first `n` items.
local function shuffle(t,n,    j)
  for i = #t, 2, -1 do
    j = randi(1,i)
    t[i], t[j] = t[j], t[i] end
  return n and top(t, n) or t end

-- **sort(t : table, ?f : fun) : table**    
-- Sort `t` based on  `f`. 
local function sort(t, f)
  table.sort(t, f)
  return t end

-- **top(t : table, n : num) : table**  
function top(t,n,         out) 
  out={}
  for i = 1,math.min(n,#t) do out[i] = t[i] end
  return out end

return {
  any=any,
  copy=copy, 
  dump=dump, 
  eq=eq, 
  keysort=keysort, 
  pump=pump, 
  shuffle=shuffle,
  sort=sort,
  top=top
}
