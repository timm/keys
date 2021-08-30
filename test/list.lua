require("rand").srand(1)
local _=require"list"
local shuffle,list,pump,eq = _.shuffle,_.list,_.pump,_.eq
local copy = _.copy

do
  local a={10,{d=100},{c=30},{1,{2,{3,{4,6}}}}}
  local b={10,{d=100},{c=30},{1,{2,{3,{4,6}}}}}
  local c={10,{d=100},{c=30},{1,{2,{3,{4,10 -- difference here
                           }}}}}
  assert(    eq(a,b))
  assert(not eq(a,c))
end

do
  local t= {"a", "b", "c", "d", "e", 
              "f", "g", "h", "i", "j", 
              "0", "1", "2", "3", "4", "5", 
              "6", "7", "8", "9" } 
  t = shuffle(t)
  assert("b" == t[1],  "could not find 'b'")
  t = shuffle(t,5)
  assert( "j" == t[1], "wanted 5 items")
  assert(  5  == #t,   "wanted 5 items")
end

do
  local t1 = {1,{2,{3,{4},5},6},7}
  local t2 = copy(t1)
  t1[2][2][2][1] = 10 
  assert(4 == t2[2][2][2][1], "wanted a 4") 
end


