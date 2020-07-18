local Class = require 'lib.class'

local BumpBox = Class {
  init = function(self, x, y, w, h)
    if x == nil then x = 0 end
    if y == nil then y = 0 end
    if w == nil then w = 1 end
    if h == nil then h = 1 end
    
    self.x = x
    self.y = y
    self.w = w
    self.h = h    
    self.collidesWithLayers = { }
    self.physicsLayer = { }
  end
}

-- gets the position by the center of the box
function BumpBox:getPosition()
  local x = self.x - w / 2
  local y = self.y - h / 2
  return x, y
end

-- gets the top left corner
function BumpBox:getBumpPosition()
  return self.x, self.y
end

return BumpBox