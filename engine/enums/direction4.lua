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

function Direction4.getOpposite(direction)
  if direction == Direction4.none then
    return Direction4.none
  end
  return (((direction - 1) + 2) % 4) + 1
end

return Direction4