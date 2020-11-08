local Class = require 'lib.class'
local Component = require 'engine.entities.component'

local AnimatedSpriteKeyDisplay = Class { __includes = Component,
  init = function(self, sprite)
    Component.init(self, true, true)
    self.sprite = sprite
    self.text = love.graphics.newText(assetManager.getFont('monogram'), '')
  end
}

function AnimatedSpriteKeyDisplay:getType()
  return 'animated_sprite_key_display'
end

function AnimatedSpriteKeyDisplay:draw()
  if self.sprite:getCurrentAnimationKey() ~= nil then
      local textValue = self.sprite:getCurrentAnimationKey()
      if self.sprite:getSubstripKey() ~= nil then
        textValue = textValue .. '[' .. self.sprite:getSubstripKey() .. ']'
      end
      
      self.text:set(textValue)
      local ex, ey = self.entity:getPosition()
      local x = ex - (self.text:getWidth() / 2)
      local y = ey - self.entity.h - self.text:getHeight() / 2
      love.graphics.draw(self.text, x, y  - self.entity:getZPosition())
  end
end

function AnimatedSpriteKeyDisplay:onRemoved(entity)
  self.text:release()
end

return AnimatedSpriteKeyDisplay