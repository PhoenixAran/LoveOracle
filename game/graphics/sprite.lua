local Class = require 'lib.class'

local Sprite = Class {
  init = function(self, subtexture, offsetX, offsetY)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end

    self.subtexture = subtexture
    self.offsetX = offsetX
    self.offsetY = offsetY
  end
}

function Sprite:getType()
  return 'sprite'
end

function Sprite:getBounds()
  local w, h = self.subtexture:getDimensions()
  return self.offsetX, self.offsetY, w, h
end

function Sprite:draw()
  --todo
end

return Sprite
