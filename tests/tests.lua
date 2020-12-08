local Of={
  synopsis="run all the .lua files in this directory (except this one)",
  get="ls"}

local fails= 0
local WHITE = "\27[0m" 
local FAIL = "\27[31m" .. " FAIL! " .. WHITE
local BOLD = "\27[35m"
local PASS = "\27[32m" .. " pass " .. WHITE
--_assert = assert
function assert(x,y) 
  if not x then fails=fails+1 end
  print("-- "..(y or "")..(x and PASS or FAIL)) end


for x in  io.popen(Of.get):lines() do
  if x:match(".lua$") then
    if x ~= "tests.lua" then
      print(BOLD .."\n------------ "..x..WHITE)
      dofile(x) end end end

assert(fails==0, "some bugs exist")
