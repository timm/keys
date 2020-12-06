local Of={
  synopsis="run all files in this rectory",
  get="ls"}

_assert = assert

function assert(x,y) 
  print("-- " .. (y or ""))
  _assert(x,y)
end

for x in  io.popen(Of.get):lines() do
  print(x)
  if x:match(".lua$") then
    if x ~= "all.lua" then
      print("---------- " .. x)
      dofile(x) end end end


