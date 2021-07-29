local md = require "md"
local htmlFragment = md[[
# This is Some Markdown
Write whatever you want.
* Supports Lists
* And other features
]]

print(htmlFragment)
