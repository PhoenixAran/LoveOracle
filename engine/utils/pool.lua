local lume = require 'lib.lume'
local pool = { }

local classes = { }
local pools = { }
local counts = { }

function pool.register(key, class)
    classes[key] = class
    pools[key] = { }
    counts[key] = 0
end

function pool.obtain(key)
  ---@type table[]
  local pTable = pools[key]
  if 0 < counts[key] then
    local result = pTable[counts[key]]
    counts[key] = counts[key] - 1
    return result
  end
  return classes[key]()
end

function pool.free(obj)
  local key = obj:getType()
  if key ~= 'player_state_parameters' then
    print('returning ' .. key)
  end

  local pTable = pools[key]
  if obj.reset then
    obj:reset()
  end
  counts[key] = counts[key] + 1
  pTable[counts[key]] = obj
end

return pool