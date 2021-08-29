--vim: filetype=lua ts=2 sw=2 sts=2 et :

-- # Stats
-- ## function sample(t:_table_)
-- Return any one item from a table.
function sample(t) 
  return t[randi(1,#t)] end

-- ## function samples(t:_table_, n:_posint_)
-- Return any  `n` items  from a table.
function samples(t,n,    t1)
  t1 = {}
  for i=1,n or #t do t1[i] = sample(t) end
  return t1 end

-- ## function same(xs:_num+_, ys:_num+_,the:_options_)
-- Check  if two lists of numbers are different
-- (as assessed by a non-parametric effect size and
-- significance test). If the lists are too large,
-- then only study a smaller sample of the lists.
function same(xs,ys, the)
  if #xs > the.sames then xs = shuffle(xs, the.sames) end
  if #ys > the.sames then ys = shuffle(ys, the.sames) end
  return cliffsDelta(xs,ys,the) and bootstrap(xs,ys, the) end

-- ## function cliffsDelta(xs:_num+_, ys:_num+_,the:_options_)
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

-- ## function bootstrap(y0:_num+_,z0:_num+_,the:_options_)
-- Non parametric "significance"  test (i.e. is it possible to
-- distinguish if an item belongs to one population of
-- another).  Uses a sampling with replacement. Warning: very
-- slow for large populations. Consider sub-sampling  for large
-- lists. Also, test the effect size (and maybe shortcut the
-- test) before applying  this test.  From p220 to 223 of the
-- Efron text  'introduction to the boostrap'.
-- https://bit.ly/3iSJz8B Typically, conf=0.05 and b is 100s to
-- 1000s.
function bootstrap(y0,z0,the,     x,y,z,xmu,ymu,zmu,yhat,zhat,tobs,n)
  x, y, z, yhat, zhat = Num:new(), Num:new(), Num:new(), {}, {}
  for _,y1 in pairs(y0) do x:add(y1); y:add(y1)           end
  for _,z1 in pairs(z0) do x:add(z1); z:add(z1)           end
  xmu, ymu, zmu = x:mu(), y:mu(), z:mu()
  -- translate both samples so that they have mean x, 
  -- the re-sample each population separately.
  for _,y1 in pairs(y0) do yhat[1+#yhat] = y1 - ymu + xmu end
  for _,z1 in pairs(z0) do zhat[1+#zhat] = z1 - zmu + xmu end
  tobs = y:delta(z)
  n = 0
  for _= 1,the.bootstrap do
    if adds(samples(yhat)):delta(adds(samples(zhat))) > tobs 
    then n = n + 1 end end
  return n / the.bootstrap >= the.conf end

-- ## function merges(nums:_num+_, ?lo:_posint_=1, ?hi:_posit_=#nums)
-- Combine the `Num`s in `nums` from `lo` to `hi`.
function merges(nums,lo,hi,    out)
  lo = lo or 1
  hi = hi or #nums
  out = nums[lo]
  for i = lo+1, hi do out = out:merge(nums[i]) end
  return out end

-- ## function scottKnow(nums:_num+_, the:_options_)
-- Do a top-down division of the `Num`s  in `nums`.
-- Divide  at the cut that maximizes  the  difference between
--  the  mean before and  after the cut. Stop cutting if
-- the top halves are statistically indistinguishable. 
function scottKnot(nums,the,      _,mu,cohen,summary,div)
  function summary(lo,hi,    out)
    out = merges(nums,lo,hi)
    return out, out:mu(), out:var()*the.iota end

  function recurse(lo, hi, rank, mu,
               _,n,cut,best,l,r,lmu,lmu1,rmu,rmu1,now)
    best = 0
    for j = lo,hi do
      if j < hi  then
        l, lmu, _ = summary(lo,  j)
        r, rmu, _ = summary(j+1, hi)
        n         = l.n + r.n
        now       = l.n/n*(lmu-mu)^2 + r.n/n*(rmu-mu)^2
        if now > best then
          if math.abs(lmu - rmu) >= cohen then
            if not l:same(r,the) then
              cut,best,lmu1,rmu1 = j,now,lmu,rmu end end end end
    end
    if cut then
      rank = recurse(lo,    cut, rank, lmu1) + 1
      rank = recurse(cut+1, hi,  rank, rmu1) 
    else
      for i = lo,hi do nums[i].rank = rank end end
    return rank end
  -------------------
  table.sort(nums, function (x,y) return x:mu() < y:mu() end) 
  _, mu, cohen = summary(1,#nums)
  recurse(1, #nums, 1, mu)
  return nums end

-- --------------------------------------------------
-- Returns:
return {sample=sample, samples=samples, same=same,
         cliffsDelta=cliffsDelta, bootstrap=bootstrap,
         merges=merges, scottKnot=scottKnot}
