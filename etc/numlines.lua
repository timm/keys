-- Number of code lines seen so far.
local total_lines_count = 0

-- Count the number of newlines in a string.
function count_lines (text)
  local count = 0
  local last_pos = 0
  repeat
    last_pos = string.find(text, '\n', last_pos + 1, true)
    count = count + 1
  until not last_pos
  return count
end

function CodeBlock (cb)
  -- do nothing for result blocks
  if not cb.classes:includes 'numberLines' then return nil end

  cb.attributes['startFrom'] = total_lines_count + 1
  total_lines_count = total_lines_count + count_lines(cb.text)
  return cb
end--lua-filter S
