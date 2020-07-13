local Class = require 'lib.class'

local Sprite = Class {
  init = function(self, subtexture, offsetX, offsetY)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end
    self.subtexture = subtexture
  end
}

return Sprite
