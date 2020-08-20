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

function TablePool.warmCache(amount)
  for i = 1, amount do
    tables[#tables + 1] = { }
  end
end

return TablePool