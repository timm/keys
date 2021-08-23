--vim: filetype=lua ts=2 sw=2 sts=2 et :

-- # class Skip
-- Columns for data that we just want to ignore.

local Skip={}

-- ## method new(at:_int_=0,  s:_string_="")
-- Create
function Skip:new(at,s) 
  return Obj.new(self,"Skip",{
    n=0, s=s or "", at=at or 0}) end

-- ## method add(x:_atom_)
-- Update.
function Skip:add(x)     return  x end

-- ## method like(x:_atom_)
-- Probability `x` belongs to this column.
function Skip:like(x,_)  return 1 end

-- ## method dist(x:_any_, y:_any_)
-- Separation `x` and `y`.
function Skip:dist(x,y)  return 0 end

return Skip
