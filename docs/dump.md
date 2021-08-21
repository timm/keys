[dump]

<h1>Keys</h1>

<b>data:</b> <a href="rows.md">rows</a>,<a href="row.md">row</a>;
<b>cols:</b> <a href="num,md">num</a>,<a href="sym.md">sym</a>,<a href="skip,md">skip</a>;
<b>functions:</b> <a href="strings.md">strings</a>,<a href="maths.md">maths</a><br>

<img width=500
src="https://user-images.githubusercontent.com/29195/130312030-beab122a-3526-4877-bcce-c8b94a387281.png">

<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

# Dump tables to string

```lua

local dump,rump,pump
```
## pump
Print  string of table
- t:table

```lua

function pump(t) print(dump(t)) end
```
## dump
Converts a table  to string (without  recursion into values)
- t:table

```lua

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
```
## rump
Print string version of a value (with
recursion into values.
- t:table
- pre:string. Prefix string (show before each entry).

```lua

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

return {dump=dump, rump=rump, pump=pump}

```
