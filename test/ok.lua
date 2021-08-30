package.path = '../src/?.lua'

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local the  = dofile"../src/cli.lua"
local str  = dofile"../src/strings.lua"
local rand = dofile"../src/rand.lua"
local list = dofile"../src/list.lua"

local fails=0
for _,f in pairs(arg) do
   if f ~= "ok.lua" and f ~= "lua" then
     rand.srand(the.seed)
     local ok,msg=  pcall(function () dofile(f) end) 
     if   ok 
     then str.color("green","%s",f)
     else fails=fails+1
          str.color("red","%s",tostring(msg)) end end end 

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
os.exit(fails)
