local Class = require 'lib.class'
local lume = require 'lib.lume'

local Entity = require 'engine.entities.entity'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local SpriteAnimationBuilder = require 'engine.utils.sprite_animation_builder'

local AnimatedSpriteRendererTest= Class {
  init = function(self)
    self.entity = Entity()
    self.sprite = nil
    self.animations = {
      'idle',
      'walking',
      'flying',
      'squish'
    }
    self.currentAnimationIndex = 1
  end
}

function AnimatedSpriteRendererTest:enter(previous, ...)
  local sb = SpriteAnimationBuilder()
  local animations = { }
  sb:setSpriteSheet('player')
  sb:setDefaultLoopType('cycle', true)
 
  -- idle
  sb:addSpriteFrame(1, 7)
  sb:setLoopType('once')
  animations['idle'] = sb:build()
  
  -- walking
  sb:addSpriteFrame(1, 7)
  sb:addSpriteFrame(1, 8)
  animations['walking'] = sb:build()
  
  -- flying
  sb:addSpriteFrame(11, 7)
  sb:addSpriteFrame(11, 8)
  animations['flying'] = sb:build()
  
  -- composite test
  sb:addSpriteFrame(21, 5)
  sb:addCompositeSprite(21, 6)
  sb:addCompositeSprite(21, 7, 0, -16)
  sb:addCompositeFrame(8, 24, 0, 0, 24)
  animations['squish'] = sb:build()
  
  self.sprite = AnimatedSpriteRenderer(animations, 'idle')
  self.entity:add(self.sprite)
  self.entity:setPosition(144 / 2 + 8, 160 / 2)
end

function AnimatedSpriteRendererTest:update(dt)
  local changed = false
  if input:pressed('up') then
    self.currentAnimationIndex = self.currentAnimationIndex - 1
    changed = true
  elseif input:pressed('down') then
    self.currentAnimationIndex = self.currentAnimationIndex + 1
    changed = true
  end
  
  if changed then
    self.currentAnimationIndex = ( (self.currentAnimationIndex - 1) % #self.animations + #self.animations) % #self.animations + 1
    self.sprite:play(self.animations[self.currentAnimationIndex])
  end
  self.entity:update(dt)
end

function AnimatedSpriteRendererTest:draw()
  self.entity:draw()
  self.entity:debugDraw()
  local x, y = 2, 2
  for i, v in ipairs(self.animations) do
    if i == self.currentAnimationIndex then
      love.graphics.setColor(100 / 255, 70 / 255, 28 / 255)
    else
      love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print(v, x, y)
    y = y + 16
  end
end

return AnimatedSpriteRendererTest