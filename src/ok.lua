local fails=0
local function run(txt,the,      it)
  the  = copy(the)
  Seed = the.seed
  it   = Eg[txt]
  if     the.wild==true 
  then   color("yellow", "now running wild:"); it.fun(the)
  elseif pcall(function () it.fun(the); end)
  then   color("green","✔ % -15s  %s",txt,it.txt); 
  else   color("red",  "✘ %-15s  %s" ,txt,it.txt); fails=fails+1 end end 
