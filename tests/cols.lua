local function main(l) 
  local c=require "cols"
  local o ,oo, any = l.o, l.oo, l.any
  local Num, Sym,Some = c.Num, c.Sym, c.Some
  
  local function going(      x,y,z)
    x = Sym.new()
    y = Num.new()
    x:add("love")
    x:add("hate")
    x:add("hate")
    y:add(20)
    y:add(30)
    assert(2==x.seen.hate,"counting symbols?")
    assert(25==y.mu,"mean?") 
    z=Num.new()
    for _,x in pairs{9,2,5,4,12,7,8,11,9,
                     3,7,4,12,5,4,10,9,6,9,4} do z:add(x) end
    assert(7 == z.mu,"mu?")
    assert(3.06 <= z.sd and z.sd <= 3.061,"sd?")
  end
  
  local function csving(   m,n)
    m=-1
    local eek=0
    for row in l.csv("../data/weather.csv") do
      n = n or #row
      m=m+1
      if m>0 and not "number" == type(row[2]) then eek=eek+1 end
      if m>0 and not #row == n then eek=eek+1 end end
    assert(eek==0,"cvs reading?") end
  
  local function diving()
    local s = l.isa(Some,{max=256})
    for _=1,10^3 do s:add( (100*math.random()^2)//1 ) end
    assert(6 == # s:bins(),"bins working?") end
  going()
  csving()
  diving()
end

-----
package.path='../src/?.lua;'.. package.path 
local l=require "lib"
math.randomseed(1)
main(l)
l.rogues()
