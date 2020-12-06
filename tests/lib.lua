local function main(l)
  ok(20   == l.any({10,20,30}),"any?")
  ok("cc" == l.split("aa, bb,cc")[3],"split?")
  
  local x={1,{3,{4,5}}}
  local y=l.copy(x)
  x[2][2][2]=10
  ok(10 ~= y[2][2][2],"copy?")
  
  for k,v in l.order({cc=1,bb=2,aa=3}) do
    ok("aa"==k,"sort keys?")
    break end
end

-----
package.path='../src/?.lua;'.. package.path 
local l=require "lib"
math.randomseed(1)
main(l)
l.rogues()
