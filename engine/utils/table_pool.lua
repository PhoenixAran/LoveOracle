local lume = require 'lib.lume'
local tables = { }
local count = 0
local TablePool = { }

function TablePool.obtain()
  if count == 0 then
    return { }
  end
  local result = tables[count]
  count = count - 1
  return result
end

function TablePool.free(table)
  count = count + 1
  tables[count] = table
end

return TablePool