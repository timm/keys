package.path = '../src/?.lua;' .. package.path

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local the=require"cli"
local rand=require"rand"
local str=requre"strings"

local fails=0
for _,f in pairs(arg) do
   rand.srand(the.seed)
   local status,err=  pcall(require(f)) 
   if status then
     list.color("green","✔ % -15s  %s",f)
   else
    fails=fails+1
    list.color("green","✔ % -15s  %s",f, tostring(err)) end end   

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
os.exit(fails)

