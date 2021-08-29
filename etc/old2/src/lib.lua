#!/usr/bin/env lua
--vim: filetype=lua ts=2 sw=2 sts=2 et :

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end

