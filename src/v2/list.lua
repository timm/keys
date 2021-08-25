local function kopy(obj, seen,      s, res)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  s = seen or {}
  res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = kopy(v, s) end
    return res end

return {kopy=kopy}
