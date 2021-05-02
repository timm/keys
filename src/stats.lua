#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Nonparametric stats
-- (c) Tim Menzies, 2021   

-- -----------------------------
local sk, sksplit, skdifferent, bootstrap, cliffsDelta
local Num=require("num")

function sk(nums,my)
  table.sort(nums,function (x,y) return x.mu < y.mu end)
  local all={}
  for _,num in pairs(nums) do
    for _,x in pairs(num._all) do all[#all+1]=x; sum0=sum0+x; n0=n0+1 end end 
  table.sort(all)
  local eps = (all[#all//9] - all[#all//1])/2.54*my.cohen
  sksplit(nums,1, #nums,eps,sum0,n0,1,0) 
  return nums end

function sksplit(nums,lo,hi,eps,s0,n0,rank,lvl)
  local best,s1,n1,s2,n2,mu0 = 0,0,0,sum0,n0,s0/n0
  local mu1,mu2,s1a,n1a,s2a,n2a
  local cut
  for j = lo,hi-1 do
     local one = nums[j]
     s1= s1 + one.sum; n1= n1 + one.n; mu1= s1/n1
     s2= s2 - one.sum; n2= n2 - one.n; mu2= s2/n2
     tmp= n1/n0*(mu1 - mu0)^2 + n2/n0*(mu2 - mu0)^2
     if tmp > best then
        cut=j
        best = tmp
        s1a,n1a,s2a,n2a = s1,n1,s2,n2
     end end
  if cut and skdifferent(nums,lo,cut,hi,eps) then
     rank = sksplit(nums,lo,   cut,eps,s1a,n1a,rank,lvl+1) + 1
     rank = sksplit(nums,cut+1,hi, eps,s2a,n2a,rank,lvl+1) 
  else
     for j=lo,hi do nums[j].rank = rank end end  
  return rank   end

function skdifferent(nums,lo,cut,hi,eps)
  local n1,n2 = isa(Num), isa(Num)
  for j=lo,cut   do for _,v1 in pairs(nums[j]._all) do n1:add(v1) end end
  for j=cut+1,hi do for _,v2 in pairs(nums[j]._all) do n2:add(v2) end end
  return (n2.mu - n1.mu) > eps and n1:different(n2) end

-- <a name=cliffsdelta>
-- Usually, are items in `xs` not smaller or greater than items in `ys`?
function cliffsDelta(xs,ys,small)
  local lt,gt,n = 0,0,0
  for _,x in pairs(xs) do
    for _,y in pairs(ys) do
      n = n + 1
      if y > x then gt = gt + 1 end
      if y < x then lt = lt + 1 end end end
  return math.abs(gt - lt)/n <= (small or .147) end

-- Using a sampling with replacement,
-- check if we  can  distinguish `self` from `them`.
function bootstrap(us,them,b,conf)
  local function sample(t, n)
    n = isa(Num)
    for i=1,#t do n:add( t[math.random(#t)] ) end
    return n 
  end
  local x,y,z = isa(Num), isa(Num), isa(Num)
  for _,v in pairs(usl) do x:add(v); y:add(v) end
  for _,v in pairs(theml) do x:add(v); z:add(v) end
  local yhat, zhat, tobs= {}, {}, y:delta(z)
  for _,v in pairs(us)   do yhat[i] = v - y.mu + x.mu end
  for _,v in pairs(them) do zhat[i] = v - z.mu + x.mu end
  local more = 0
  b = b or 512
  for _ = 1,b  do
    if sample(yhat):delta(sample(zhat)) > tobs then more = more + 1 end end
  return more/b <= (conf or 0.05)  end

return {sk=sk,cliffsDelta=cliffsDelta}

