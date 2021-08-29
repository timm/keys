--vim: filetype=lua ts=2 sw=2 sts=2 et :

local eg,shuffle,top,sorted,sort,per,inc,max

-- ### List Functions
function eq(a,b,    ta,tb)
   ta, tb = type(a), type(b)
   if ta ~= tb                              then return false end
   if ta ~= 'table' and tb ~= 'table'       then return a == b end
   for k,v in pairs(a) do if not eq(v,b[k]) then return false end end
   for k,v in pairs(b) do if not eq(v,a[k]) then return false end end
   return true
end

-- shuffles, in place the table `a`
function shuffle(a,n,    j)
  for i = #a, 2, -1 do
    j = randi(1,i)
    a[i], a[j] = a[j], a[i] end
  return n and top(a, n) or a end

function top(a,n,         b) 
  b={}
  for i=1, math.min(n,#a) do b[i] = a[i] end
  return b end

function sorted(t,         i,keys)
  i,keys = 0,{}
  for k,_ in pairs(t) do keys[1 + #keys] = k end
  table.sort(keys)
  return function ()
    if i < #keys then
      i=i+1; return keys[i], t[keys[i]] end end end

function sort(a, f)
  f = fun(f)
  table.sort(a, function(x,y) return f(x)<f(y) end)
  return a end

function per(a,p) 
  return a[math.max(1,math.floor(#a*(p or .5)))] end

function inc(t,k,n)
  t[k] = (t[k] or 0) + (n or 1)
  return t[k] end

function max(t,k,n) t[k] = math.max(n or 0, (t[k] or 0)) end

return {
  eq=eq, shuffle=shuffle, top=top, sorted=sorted, 
  sort=sort, per=per, inc=inc, max=max}
