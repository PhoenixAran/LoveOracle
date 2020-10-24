local Class = require 'lib.class'
local Component = require 'engine.entities.component'

local AnimatedSpriteKeyDisplay = Class { __includes = Component,
  init = function(self, sprite)
    Component.init(self, true, true)
    self.sprite = sprite
  end
}

function AnimatedSpriteKeyDisplay:getType()
  return 'animatedspritekeydisplay'
end

function AnimatedSpriteKeyDisplay:draw()
  if self.sprite:getCurrentAnimationKey() ~= nil then
      local text = love.graphics.newText(assetManager.getFont('monogram'), self.sprite:getCurrentAnimationKey())
      local ex, ey = self.entity:getPosition()
      local x = ex - (text:getWidth() / 2)
      local y = ey - self.entity.h - text:getHeight() / 2
      love.graphics.draw(text, x, y)
      text:release()
  end
end


return AnimatedSpriteKeyDisplay