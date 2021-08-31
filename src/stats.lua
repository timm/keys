local same,cliffsDelta,bootstrap
local Num=require"num"

-- **cliffsDelta(xs:number+, ys:number+, the:table)**   
function same(xs,ys, the)
  if #xs > the.sames then xs = shuffle(xs, the.sames) end
  if #ys > the.sames then ys = shuffle(ys, the.sames) end
  return cliffsDelta(xs,ys,the) and bootstrap(xs,ys, the) end

-- **cliffsDelta(xs : number+, ys : number+, the : table)**    
-- Non parametric effect size test (i.e. are two distributions
-- different by more than a small amount). Slow for large lists
-- (hint: sub-sample large lists).  Thresholds here set from
-- top of p14 of  https://bit.ly/3m9Q0pP .  0.147 (small), 0.33
-- (medium), and 0.474 (large)
function cliffsDelta(xs,ys,the,       lt,gt)
  lt,gt = 0,0
  for _,x in pairs(xs) do
    for _,y in pairs(ys) do
      if y > x then gt = gt + 1 end
      if y < x then lt = lt + 1 end end end
  return math.abs(gt - lt)/(#xs * #ys) <= the.cliffs end

-- **bootstrap(y0 : num+, z0 : num+, the : table)**    
-- Non parametric "significance"  test (i.e. is it possible to
-- distinguish if an item belongs to one population of
-- another).  Uses a sampling with replacement. Warning: very
-- slow for large populations. Consider sub-sampling  for large
-- lists. Also, test the effect size (and maybe shortcut the
-- test) before applying  this test.  From p220 to 223 of the
-- Efron text  'introduction to the boostrap'.
-- https://bit.ly/3iSJz8B Typically, conf=0.05 and b is 100s to
-- 1000s.
-- Translate both samples so that they have mean x, 
-- The re-sample each population separately.
function bootstrap(y0,z0,the,     x,y,z,xmu,ymu,zmu,yhat,zhat,tobs,n)
  x, y, z, yhat, zhat = Num:new(), Num:new(), Num:new(), {}, {}
  for _,y1 in pairs(y0) do x:add(y1); y:add(y1)           end
  for _,z1 in pairs(z0) do x:add(z1); z:add(z1)           end
  xmu, ymu, zmu = x.mu, y.mu, z.mu
  for _,y1 in pairs(y0) do yhat[1+#yhat] = y1 - ymu + xmu end
  for _,z1 in pairs(z0) do zhat[1+#zhat] = z1 - zmu + xmu end
  tobs = y:delta(z)
  n = 0
  for _= 1,the.bootstrap do
    if adds(samples(yhat)):delta(adds(samples(zhat))) > tobs 
    then n = n + 1 end end
  return n / the.bootstrap >= the.conf end

-- **function scottKnow(nums:_num+_, the:_options_)**   
-- Do a top-down division of the `Num`s  in `nums`.
-- Divide  at the cut that maximizes  the  difference between
--  the  mean before and  after the cut. Stop cutting if
-- the top halves are statistically indistinguishable. 
function scottKnot(nums,the,      all,cohen)
  local mid = function (z) return z.some:mid() end

  local function summary(i,j,    out)
    out = copy( nums[i] )
    for k = i+1, j do out = out:merge(nums[k]) end
    return out end 

  local function div(lo,hi,rank,b4,       cut,best,l,l1,r,r1,now)
    best = 0
    for j = lo,hi do
      if j < hi  then
        l   = summary(lo,  j)
        r   = summary(j+1, hi)
        now = (l.n*(mid(l) - mid(b4))^2 + r.n*(mid(r) - mid(b4))^2
              ) / (l.n + r.n)
        if now > best then
          if math.abs(mid(l) - mid(r)) >= cohen then
            cut, best, l1, r1 = j, now, copy(l), copy(r) 
    end end end end
    if cut and not l1:same(r1,the) then
      rank = div(lo,    cut, rank, l1) + 1
      rank = div(cut+1, hi,  rank, r1) 
    else
      for i = lo,hi do nums[i].rank = rank end end
    return rank end 

  table.sort(nums, function(x,y) return mid(x) < mid(y) end)
  all   = summary(1,#nums)
  cohen = all.sd * the.iota
  div(1, #nums, 1, all)
  return nums end

-- --------------
return {same=same, cliffsDelta=cliffsDelta, bootstrap=bootstrap} 
