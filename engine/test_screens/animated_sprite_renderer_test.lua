local Class = require 'lib.class'
local lume = require 'lib.lume'
local BaseScreen = require 'engine.screens.base_screen'

local Entity = require 'engine.entities.entity'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local SpriteAnimationBuilder = require 'engine.utils.sprite_animation_builder'
local Direction4 = require 'engine.enums.direction4'

local AnimatedSpriteRendererTest = Class { __includes = BaseScreen,
  init = function(self)
    self.entity = Entity()
    self.sprite = nil
    self.animations = {
      'idle',
      { 'walk', 'down'},
      { 'walk', 'up' },
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
  sb:addSpriteFrame(7, 1)
  sb:setLoopType('once')
  animations['idle'] = sb:build()

  -- walking
  sb:setSubstrips(true)

  sb:addSpriteFrame(7, 1)
  sb:addSpriteFrame(8, 1)
  sb:buildSubstrip('down', true)

  sb:addSpriteFrame(3, 1)
  sb:addSpriteFrame(4, 1)
  sb:buildSubstrip('up')
  animations['walk'] = sb:build()

  -- flying
  sb:addSpriteFrame(7, 11)
  sb:addSpriteFrame(8, 11)
  animations['flying'] = sb:build()

  -- composite test
  sb:addSpriteFrame(5, 21)
  sb:addCompositeSprite(6, 21)
  sb:addCompositeSprite(7, 21, 0, -16)
  sb:addCompositeFrame(24, 8, 0, 0, 24)
  animations['squish'] = sb:build()

  self.sprite = AnimatedSpriteRenderer(self.entity, {
    animations = animations,
    defaultAnimation = 'idle'
  })
  self.entity:initTransform()
  self.entity:setPosition(144 / 2 + 8, 160 / 2)
end

function AnimatedSpriteRendererTest:update(dt)
  -- dark times before Slab library lol
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
    local animation = self.animations[self.currentAnimationIndex]
    if type(animation) == 'table' then
      self.sprite:play(animation[1], Direction4[animation[2]])
    else
      self.sprite:play(animation)
    end
  end
  self.sprite:update(dt)
end

function AnimatedSpriteRendererTest:draw()
  monocle:begin()
  self.sprite:draw()
  local x, y = 2, 2
  for i, v in ipairs(self.animations) do
    if i == self.currentAnimationIndex then
      love.graphics.setColor(100 / 255, 70 / 255, 28 / 255)
    else
      love.graphics.setColor(1, 1, 1)
    end
    if type(v) == 'table' then
      love.graphics.print(v[1] .. v[2], x, y)
    else
      love.graphics.print(v, x, y)
    end
    y = y + 16
  end
  monocle:finish()
end

return AnimatedSpriteRendererTest