local function main(l)
  local t=require "tbl"
  local o ,oo, any = l.o, l.oo, l.any
  local Tbl = t.Tbl
  
  local function rowsreading()
    local tbl = Tbl.read("data/auto93.csv")
    ok("Num"==tbl.cols[2].ako,"is Num?")
    ok(#tbl.rows==398,"auto has rows?") end
  
  local function rowsdist()
    local tbl = Tbl.read("data/weather.csv")
      local r1,r2 = tbl.rows[3], tbl.rows[4]
      ok(5 == #r1.cells,"rows have cells?")
      ok(5 == #r1.bins,"bins have cells?")
      ok(0<=  r1:dist(r2,tbl.xs),"dist functioning?" ) end
  
  local function rowsdists()
    local tbl = Tbl.read("data/auto93.csv")
    local all={}
    local insane=0
    for i=1,10 do
      local r1,r2 = any(tbl.rows), any(tbl.rows)
      local one ={r1=r1.cells, r2=r2.cells}
      one.d = r1:dist(r2,tbl.xs) 
      all[#all+1] = one
      if (0< r1:dist(r1,tbl.xs)) then insane=insane+1 end
    end
    ok(0 == insane,  "sane distance?") 
    table.sort(all, function(x,y) return x.d < y.d end)
    ok(all[1].d < all[#all].d,"row distances?")
    -- for _,one in pairs(tbl.xs) do print(one.pos) end
    -- for _,one in pairs(all) do print(""); print(one.d); o(one.r1); o(one.r2) end 
    end
  
  local function binnings()
    local tbl = Tbl.read("data/auto93.csv")
    tbl:bins() 
    ok(true,"bins runs?") end 
  rowsreading()
  rowsdist()
  rowsdists()
  binnings()
end

------
package.path='../src/?.lua;'.. package.path 
local l=require "lib"
math.randomseed(1)
main(l)
l.rogues()
