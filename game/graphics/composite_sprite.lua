local Class = require 'lib.class'

local CompositeSprite = Class {
  init = function(self, sprites, offsetX, offsetY)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end

    self.image = image
    self.sprites = sprites
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.boundsRect = { }
    self:calculateBounds()
  end
}

function CompositeSprite:getType()
  return 'compositesprite'
end

function CompositeSprite:draw()
  for _, sprite in ipairs(self.sprites) do
    sprite:draw()
  end
end

function CompositeSprite:calculateBounds()
  
end

return CompositeSprite