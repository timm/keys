local Of={
  synopsis="run all files in this rectory",
  get="ls"}

local fails= 0
local WHITE = "\27[0m" 
local RED = "\27[31m"
local GREEN = "\27[32m"
local BOLD = "\27[35m"
local FAIL = RED .. " FAIL! " .. WHITE
local PASS = GREEN .. " pass " .. WHITE
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
