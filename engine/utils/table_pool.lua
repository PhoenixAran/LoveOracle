local lume = require 'lib.lume'
local tables = { }
local TablePool = { }

function TablePool.obtain()
  if #tables < 1 then
    return { }
  end
  return table.remove(tables, #tables)
end

function TablePool.free(table)
  lume.clear(table)
  tables[#tables + 1]  = table
end

return TablePool