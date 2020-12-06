local Of={
  synopsis="run all files in this rectory",
  get="ls"}

--_assert = assert
-- function assert(x,y) print("-- " .. (y or ""));pcall(_assert(x,y) ) end

for x in  io.popen(Of.get):lines() do
  if x:match(".lua$") then
    if x ~= "tests.lua" then
      print("\n---------- " .. x)
      dofile(x) end end end


