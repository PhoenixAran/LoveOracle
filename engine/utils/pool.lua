local lume = require 'lib.lume'
local pool = { }

local classes = { }
local pools = { }

function pool.register(key, class)
    classes[key] = class
    pools[key] = { }
end

function pool.obtain(key)
  local pTable = pools[key]
  -- return cached object
  if 0 < lume.count(pTable) then
    local index = lume.count(pTable)
    local returnValue = pTable[index]
    table.remove(pTable, index)
    return returnValue
  end
  -- create new object
  return classes[key]()
end

function pool.free(obj)
  if obj.reset then
    obj:reset()
  end
  local table = pools[obj:getType()]
  lume.push(table, obj)
end

return pool