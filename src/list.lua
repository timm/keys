-- # List functions
-- |**Functions**|list  |: category= util |
-- |---------|-------:|------------------|
-- |**Does** | 1      |: meta-level reasoning|
-- |         | 2      |: comparions |
-- |         | 3      |: copying |
-- |         | 4      |: sorting |
-- |         | 5      |: sampling |
-- |         | 6      |: printing |
-- |         | y      |: all the dependent columns|  
-- |**Uses** |        |: [rand](rand.html) |
local randi=require("rand").randi

-- ------------------
-- ## Meta
-- **map(t :table, ?f :function): table**   
-- map function `f` over all items in `t`.
local function map(t,f,     b)
  b, f = {}, f or function(z) return z end
  for i,v in pairs(t or {}) do b[i] = f(v) end 
  return b end 

-- -------------------
-- ## Comparison
-- **eq(a :any, b :any) : bool**    
-- Recursive check if two tables are equal.
local function eq(a,b,    ta,tb)
  ta, tb = type(a), type(b)
  if ta ~= tb                              then return false end
  if ta ~= 'table' and tb ~= 'table'       then return a == b end
  for k,v in pairs(a) do if not eq(v,b[k]) then return false end end
  for k,v in pairs(b) do if not eq(v,a[k]) then return false end end
  return true end

-- -------------------
-- ## Copying
-- **copy(t :table) : table**    
-- Return a deep copy of `t`.
local function copy(t,      seen,      res) 
  seen = seen or {}
  if type(t) ~= 'table' then return t end
  if seen[t] then return seen[t] end
  res = setmetatable({}, getmetatable(t))
  seen[t] = res
  for k,v in pairs(t) do res[copy(k,seen)]=copy(v,seen) end
  return res end

-- ---------------
-- ## Sorting
-- **keysort(t :table, ?key  :atom) : table**    
-- Sort `t` based on  `x[key]`. 
local function keysort(t, key)
  table.sort(t, function(x,y) return x[key]<y[key] end)
  return t end

-- **sort(t :table, ?f :fun) : table**    
-- Sort `t` based on  `f`. 
local function sort(t, f)
  table.sort(t, f)
  return t end

-- ---------
-- ## Sampling
-- **any(t :table) : any**    
-- Return any item for `t`.
local function any(t) return t[ randi(1,#t) ] end

-- **top(t :table, n :num) : table**  
local function top(t,n,         out) 
  out={}
  for i = 1,math.min(n,#t) do out[i] = t[i] end
  return out end

-- **shuffle(t :table, n :number) : table**   
-- Shuffles, in place the table `t`. If `n`
-- supplied, then return the  first `n` items.
local function shuffle(t,n,    j)
  for i = #t, 2, -1 do
    j = randi(1,i)
    t[i], t[j] = t[j], t[i] end
  return n and top(t, n) or t end

-- --------
-- ## Printing
-- **dump(t :table) : str**       
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

-- **pump(t :table)**    
-- Print a string for key:value  in `t`. 
local function pump(t)
  print(dump(t)) end

-- **fmts(t :table, ?w :num=5, ?d :num=2): {string}**    
-- Return a list of strings where any items are `w` width and all numberics have `d` decimal places
local function fmts(t, w,d,       num)
  w,d = w or 5, d or 2
  num = table.concat({"%",w,".",d,"f"})
  return map(t, function (z,    s) 
      if   type(z)=="number" 
      then return string.format(num,z)
      else s= tostring(z)
           return string.sub(s,1,math.min(w,#s)) end end) end

-- -----
-- Return 
return {
  any=any,
  copy=copy, 
  dump=dump, 
  eq=eq, 
  fmts=fmts,
  keysort=keysort, 
  map=map,
  pump=pump, 
  shuffle=shuffle,
  sort=sort,
  top=top
}
