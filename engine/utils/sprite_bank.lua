local Class = require 'lib.class'
local lume = require 'lib.lume'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local SpriteRenderer = require 'engine.components.animated_sprite_renderer'
local fh = require 'engine.utils.file_helper'
local SpriteAnimationBuilder = require 'engine.utils.sprite_animation_builder'

-- friend type
local SpriteBankPayload = Class {
  init = function(self)
    self.sprites = { }
    self.animations = { }
  end
}

-- friend type
-- builds AnimatedSpriteRenderers
local SpriteBuilder = Class {
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

function SpriteBuilder:createSpriteAnimationBuilder()
  return SpriteAnimationBuilder()
end


function SpriteBuilder:setDefaultAnimation(value)
  self.defaultAnimation = value
end

function SpriteBuilder:build()
  assert(self.type == 'animated_sprite_renderer' or self.type == 'sprite_renderer', 'Invalid type in SpriteBuilder: ' .. tostring(self.type))
  assert(spriteBank, 'Global variable "spriteBank" does not exist')
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
    return AnimatedSpriteRenderer(animations, self.defaultAnimation, self.offsetX, self.offsetY, self.followZ)
  end
end

function SpriteBuilder:addAnimation(key, animation)
  self.animations[key] = animation
end

function SpriteBuilder:addDeferredAnimation(animationKey, realKey)
  if realKey == nil then realKey = animationKey end
  self.deferredAnimations[key] = realKey
end

function SpriteBuilder:setFollowZ(value)
  self.followZ = value
end

-- export type
local SpriteBank = { 
  -- holds singular sprite instances
  sprites = { },
  -- holds individual sprite animations
  -- useful for shared animation such as death effects or breaking animations
  animations = { },
  -- holds AnimatedSpriteBuilder instances
  builders = { }
}

-- getters and setters for caches
function SpriteBank.registerSprite(key, sprite)
  assert(not SpriteBank.sprites[key], 'SpriteBank already has sprite with key ' .. key)
  SpriteBank.sprites[key] = sprite
end

function SpriteBank.getSprite(key)
  assert(SpriteBank.sprites[key], 'SpriteBank does not have sprite with key ' .. key)
  return SpriteBank.sprites[key]
end

function SpriteBank.registerAnimation(key, spriteAnimation)
  assert(not SpriteBank.animations[key], 'SpriteBank already has SpriteAnimation with key ' .. key)
  SpriteBank.animations[key] = spriteAnimation
end

function SpriteBank.getAnimation(key)
  assert(SpriteBank.animations[key], 'SpriteBank does not have SpriteAnimation with key ' .. key)
  return SpriteBank.animations[key]
end

function SpriteBank.registerBuilder(key, builder)
  assert(not SpriteBank.builders[key], 'SpriteBank already has SpriteBuilder with key ' .. key)
  SpriteBank.builders[key] = builder
end

function SpriteBank.build(key)
  assert(SpriteBank.builders[key], 'SpriteBank does not have SpriteBuilder with key ' .. key)
  return SpriteBank.builders[key]:build()
end

function SpriteBank.receivePayload(payload)
  for k, v in pairs(payload.sprites) do
    SpriteBank.registerSprite(k, v)
  end
  for k, v in pairs(payload.animations) do
    SpriteBank.registerAnimation(k, v)
  end
end

function SpriteBank.initialize(directory)
  local files = love.filesystem.getDirectoryItems(directory)
  for _, file in ipairs(files) do
    local path = directory .. '/' .. file
    if love.filesystem.getInfo(path).type == 'directory' then
      SpriteBank.initialize(path)
    else
      local requirePath = fh.getFilePathWithoutExtension(path):gsub('%/', '.')
      local builder = require(requirePath)
      if builder.fillPayload then
        local payload = SpriteBankPayload()
        builder.fillPayload(payload)
        SpriteBank.receivePayload(payload)
      end
      if builder.configureSpriteBuilder then
        local spriteBuilder = SpriteBuilder()
        builder.configureSpriteBuilder(spriteBuilder)
        SpriteBank.registerBuilder(builder.getKey(), spriteBuilder)
      end
    end
  end
end

return SpriteBank