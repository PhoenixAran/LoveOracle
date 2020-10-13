local Class = require 'lib.class'
local lume = require 'lib.lume'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local SpriteRenderer = require 'engine.components.animated_sprite_renderer'
local fh = require 'engine.utils.file_helper'


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
    self.key = nil
    self.type = nil
    
    -- used if type is 'animatedsprite'
    self.animations = { }
    self.deferredAnimations = { }
    
    -- used if type is 'sprite'
    self.sprite = nil
    self.deferredSprite = nil
    
    -- shared between animatedsprite and sprite
    self.offsetX, self.offsetY = 0, 0
  end
}

function SpriteBuilder:getKey()
  return self.key
end

function SpriteBuilder:build()
  assert(self.type == 'animatedspriterenderer' or self.type == 'spriterenderer', 'Invalid type in SpriteBuilder: ' .. self.type)
  assert(spriteBank, 'Global variable "spriteBank" does not exist')
  if self.type == 'spriterenderer' then
    if self.sprite == nil then
       -- use deferred sprite
      return SpriteRenderer(spriteBank.getSprite(self.deferredSprite), self.offsetX, self.offsetY)
    else
      -- use sprite in SpriteBuilder instance
      return SpriteRenderer(self.sprite, self.offsetX, self.offsetY)
    end
  elseif self.type == 'animatedspriterenderer' then
    local animations = { }
    lume.merge(animations, self.animations)
    for k, v in pairs(self.deferredAnimations) do
      animations[k] = spriteBank.getAnimation(v)
    end
    return AnimatedSpriteRenderer()
  end
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
  assert(SpriteBank.bulders[key], 'SpriteBank does not have SpriteBuilder with key ' .. key)
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

-- assumes flat directory because i'm lazy
function SpriteBank.initialize(directory)
  local files = love.filesystem.getDirectoryItems(directory)
  for _, file in ipairs(files) do
    local requirePath = fh.getFilePathWithoutExtension(directory .. '/' .. file):gsub('%/', '.')
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
return SpriteBank