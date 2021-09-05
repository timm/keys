
-- # class Range
-- |**Class**|Range   |: category= data |
-- |---------|-------:|------------------|
-- |**Does** | 1      |: explores lists of (x:num, y:sym), sorted on `num` |
-- |         | 2      |: finds ranges that split the `x` values into not-small chunks |
-- |         | 3      |: combines ranges that do not change the `y` distribution|
-- |**Has**  | x:Num  |: info about the `x` values |
-- |         | y:Sym  |: info about the `y` values |
-- |**Uses** |        |: [Num](num.html),  [Sym](sym.html)|   
local Sample={}
local Num = require"num"
local Sym = require"sym"
local obj = require"obj"

function 
