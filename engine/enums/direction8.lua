local vector = require 'lib.vector'

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
      error('Direction out of range for Direction4.getDirection: ' .. tostring(x))
    end
    return direction
  else
    if vecx == 0 and vecy == 0 then
      return Direction4.NONE
    end
    local theta = math.atan2(y, x)
    if theta < 0 then
      theta = theta + math.pi * 2
    end
    local angleInterval =  (math.pi * 2) / 8
    local angleIndex = math.floor((theta / angleInterval) + 0.5)
    return angleIndex + 1
  end
end

return Direction8