local vector = require 'engine.math.vector'
local lume = require 'lib.lume'

-- values determined by angleindex + 1
---@enum Direction8
local Direction8 = {
  none = 0,
  right = 1,
  downRight = 2,
  down = 3,
  downLeft = 4,
  left = 5,
  upLeft = 6,
  up = 7,
  upRight = 8
}

local direction8VectorMap = {
  [Direction8.none] = { x = 0, y = 0 },
  [Direction8.right] = { x = 1, y = 0 },
  [Direction8.downRight] = { x = 1, y = 1},
  [Direction8.down] = { x = 0, y = 1 },
  [Direction8.downLeft] = { x = -1, y = 1 },
  [Direction8.left] = { x = -1, y = 0 },
  [Direction8.upLeft] = { x = -1, y = -1 },
  [Direction8.up] = { x = 0, y = -1 },
  [Direction8.upRight] = { x = 1, y = -1 }
}

function Direction8.getDirection(x, y)
  if type(x) == 'string' then
    local direction = Direction8[x]
    if direction == nil then
      error('Direction out of range for Direction8.getDirection: ' .. tostring(x))
    end
    return direction
  else
    if x == 0 and y == 0 then
      return Direction8.none
    end
    local theta = math.atan2(y, x)
    if theta < 0 then
      theta = theta + (math.pi * 2)
    end
    local angleInterval = (math.pi * 2) / 8
    local angleIndex = math.floor((theta / angleInterval) + 0.5)
    return (angleIndex - (math.floor(angleIndex / 8) * 8)) + 1
  end
end

---get vector from Direction8 value
---@param dir8 integer
---@return integer, integer
function Direction8.getVector(dir8)
  local vectorTable = direction8VectorMap[dir8]
  if direction8VectorMap[dir8] then
    return vectorTable.x, vectorTable.y
  end
  error('Direction8 out of range')
end

function Direction8.debugString(dir8)
  if dir8 == 0 then
    print 'none'
  elseif dir8 == 1 then
    print 'right'
  elseif dir8  == 2 then
    print 'downRight'
  elseif dir8 == 3 then
    print 'down'
  elseif dir8 == 4 then
    print 'downLeft'
  elseif dir8 == 5 then
    print 'left'
  elseif dir8 == 6 then
    print 'upLeft'
  elseif dir8 == 7 then
    print 'up'
  elseif dir8 == 8 then
    print 'upRight'
  end
end

return Direction8