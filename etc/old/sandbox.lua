function keys(t,    i,v) return function() i,v=next(t,i); return i end  end                                                                           
function vals(t,    i,v) return function() i,v=next(t,i); return v end  end                                                                           
for v in  keys({a=1,b=2,c=3}) do print(v) end
for v in  vals({a=1,b=2,c=3}) do print(v) end

