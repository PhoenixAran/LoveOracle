local Class = require 'lib.class'
local lume = require 'lib.lume'
local SpriteRenderer = require 'engine.components.animated_sprite_renderer'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'

local SpriteRendererBuilder = Class {
  init = function(self)
    -- by default this is used to configure an animated sprite
    -- its the most common use case
    self.type = 'animated_sprite_renderer'
    -- used if type is 'animatedsprite'
    self.animations = { }
    self.deferredAnimations = { }
    self.defaultAnimation = nil
    
    -- used if type is 'sprite'
    self.sprite = nil
    self.deferredSprite = nil
    
    -- shared between animatedsprite and sprite
    self.offsetX, self.offsetY = 0, 0
    self.followZ = true
  end
}

function SpriteRendererBuilder:setDefaultAnimation(value)
  self.defaultAnimation = value
end

function SpriteRendererBuilder:build(entity)
  if self.type == 'sprite_renderer' then
    if self.sprite == nil then
       -- use deferred sprite
      return SpriteRenderer(spriteBank.getSprite(self.deferredSprite), self.offsetX, self.offsetY, self.followZ)
    else
      -- use sprite in SpriteBuilder instance
      return SpriteRenderer(self.sprite, self.offsetX, self.offsetY, self.followZ)
    end
  elseif self.type == 'animated_sprite_renderer' then
    local animations = { }
    animations = lume.merge(animations, self.animations)
    for k, v in pairs(self.deferredAnimations) do
      animations[k] = spriteBank.getAnimation(v)
    end
    return AnimatedSpriteRenderer(entity, animations, self.defaultAnimation, self.offsetX, self.offsetY, self.followZ)
  end
end

function SpriteRendererBuilder:addAnimation(key, animation)
  self.animations[key] = animation
end

function SpriteRendererBuilder:addDeferredAnimation(animationKey, realKey)
  if realKey == nil then realKey = animationKey end
  self.deferredAnimations[key] = realKey
end

function SpriteRendererBuilder:setFollowZ(value)
  self.followZ = value
end


return SpriteRendererBuilder