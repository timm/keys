local Of={
  synopsis="run all files in this rectory",
  get="ls"}

local fails=0
--_assert = assert
function assert(x,y) 
  if not x then fails=fails+1 end
  print("-- " .. (y or "") .. (x and "" or " FAIL!!!! ")) end


for x in  io.popen(Of.get):lines() do
  if x:match(".lua$") then
    if x ~= "tests.lua" then
      print("\n---------- " .. x)
      dofile(x) end end end

assert(fails==0, "some bugs exist")
