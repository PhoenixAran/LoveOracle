local Class = require 'lib.class'
local lume = require 'lib.lume'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'

local SpriteRendererBuilder = Class {
  init = function(self)
    -- by default this is used to configure an animated sprite
    -- its the most common use case
    self.type = 'animated_sprite_renderer'
    -- used if type is 'animatedsprite'
    self.animations = { }

    -- used if type is 'sprite'
    self.sprite = nil
    self.deferredSprite = nil

    -- shared between animatedsprite and sprite
    self.offsetX, self.offsetY = 0, 0
    self.followZ = true
  end
}

function SpriteRendererBuilder:getType()
  return 'sprite_renderer_builder'
end

function SpriteRendererBuilder:setDefaultAnimation(value)
  self.defaultAnimation = value
end

function SpriteRendererBuilder:build(entity)
  if self.type == 'sprite_renderer' then
      -- use sprite in SpriteBuilder instance
      -- return SpriteRenderer(self.sprite, self.offsetX, self.offsetY, self.followZ)
      return SpriteRenderer(entity, {
        sprite = self.sprite,
        offsetX = self.offsetX,
        offsetY = self.offsetY,
        followZ = self.followZ
      })
  elseif self.type == 'animated_sprite_renderer' then
    local animations = { }
    animations = lume.merge(animations, self.animations)
    return AnimatedSpriteRenderer(entity, {
      animations = animations,
      defaultAnimation = self.defaultAnimation,
      offsetX = self.offsetX,
      offsetY = self.offsetY,
      followZ = self.followZ
    })
  end
end

function SpriteRendererBuilder:addAnimation(key, animation)
  self.animations[key] = animation
end

function SpriteRendererBuilder:setFollowZ(value)
  self.followZ = value
end

return SpriteRendererBuilder