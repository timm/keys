-- Columns for things we just ignore.     
-- Tim Menzies, (c) 2021, MIT     
-- [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4728990.svg)](https://doi.org/10.5281/zenodo.4728990)
-- ![](https://img.shields.io/badge/language-lua,bash-orange)
-- ![](https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet)
-- [![Build Status](https://travis-ci.com/timm/keys.svg?branch=main)](https://travis-ci.com/timm/keys)
-- [![](https://img.shields.io/badge/license-mit-lightgrey)](http://github.com/timm/keys/blob/main/LICENSE.md)<br>   
-- [docs](http://menzies.us/keys/index.html) | [github](http://github.com/timm/keys/blob/main/README.md)

-- ---------------------------------------------

local Skip= {at=0, txt="", n=0}

function Skip:add(x) return true end
function Skip:mid()  return "?" end

return Skip
