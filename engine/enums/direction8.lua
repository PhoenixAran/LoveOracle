local vector = require 'lib.vector'
local lume = require 'lib.lume'

-- values determined by angleindex + 1
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

return Direction8