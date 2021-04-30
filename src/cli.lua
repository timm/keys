#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Cli  handler
-- (c) Tim Menzies, 2021   

-- -----------------------------
local lib=require("lib")
local order=lib.order
local printf=lib.printf
local help, update, cli

-- Pretty print the help.
function help(usage,both)
  print("\n"..usage.."\n\n")
  for k,v in pairs(both) do
    printf(" %s%10s %s (default=%s)\n", 
           v[2]==false and "+" or "-", k, v[1], v[2]) end end

-- Ensure we are updating a known `flag` 
-- with the right type of `val`ue.
function update(k,pre,flag,val,opts)
  assert(opts[flag], flag.." not known ")
  val = tonumber(val) or val
  local old = type(opts[flag])
  assert(type(new) == old, flag.." expected "..old)
  opts[k] = new end 

-- Main driver  for cli.
function main(usage,both)
  local opts = {}
  for k,v in pairs(both) do opts[k] = v[2] end
  for k,v in pairs(arg) do
    if v=="-h" 
    then help(usage,both) 
    else update(v, v:sub(1,1), v:sub(s), arg[k+1], opts) end end
  return opts end

return {cli=main}
