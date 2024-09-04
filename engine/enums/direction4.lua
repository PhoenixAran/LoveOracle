---@diagnostic disable: inject-field
local vector = require 'engine.math.vector'
local lume = require 'lib.lume'

-- values determined by angleindex + 1
---@enum Direction4
local Direction4 = {
  none = 0,
  right = 1,
  down = 2,
  left = 3,
  up = 4
}

local direction4VectorMap = {
  [Direction4.none] = { x = 0, y = 0 },
  [Direction4.right] = { x = 1, y = 0 },
  [Direction4.down] = { x = 0, y = 1 },
  [Direction4.left] = { x = -1, y = 0 },
  [Direction4.up] = { x = 0, y = -1  }
}

---get Direction4 enum value from vector or string name
---@param x number|string
---@param y number
---@return integer
function Direction4.getDirection(x, y)
  if type(x) == 'string' then
    local direction = Direction4[x]
    if direction == nil then
      error('Direction out of range for Direction4.getDirection: ' .. tostring(x))
    end
    return direction
  else
    if x == 0 and y == 0 then
      return Direction4.none
    end
    local theta = math.atan2(y, x)
    if theta < 0 then
      theta = theta + math.pi * 2
    end
    local angleInterval =  (math.pi * 2) / 4
    local angleIndex = math.floor((theta / angleInterval) + 0.5)
    return (angleIndex - (math.floor(angleIndex / 4) * 4)) + 1
  end
end

---get the opposite direction4 given a direction
---@param direction integer
---@return integer
function Direction4.getOpposite(direction)
  if direction == Direction4.none then
    return Direction4.none
  end
  return (((direction - 1) + 2) % 4) + 1
end

---get vector from Direction4 value
---@param dir4 integer
---@return integer, integer
function Direction4.getVector(dir4)
  local vectorTable = direction4VectorMap[dir4]
  if direction4VectorMap[dir4] then
    return vectorTable.x, vectorTable.y
  end
  error('Direction4 out of range')
end

return Direction4