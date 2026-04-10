local Class = require 'lib.class'
local lume = require 'lib.lume'

local SpriteBuilder = require 'engine.utils.sprite_builder'
local SpriteRendererBuilder = require 'engine.utils.sprite_renderer_builder'
local SpriteAnimationBuilder = require 'engine.utils.sprite_animation_builder'
local Spriteset = require 'engine.graphics.spriteset'
local NinePatchTexture = require 'engine.graphics.nine_patch_texture'
local Subtexture = require 'engine.graphics.subtexture'

local SpriteRenderer = require 'engine.components.animated_sprite_renderer'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local fh = require 'engine.utils.file_helper'

-- export type
---@class SpriteBank
---@field sprites table<string, Sprite>
---@field animations table<string, SpriteAnimation>
---@field builders table<string, SpriteRendererBuilder>
local SpriteBank = {
  -- holds singular sprite instances
  sprites = { },
  -- holds individual sprite animations
  -- useful for shared animation such as death effects or breaking animations
  animations = { },
  -- holds SpriteRendererBuilder instances
  builders = { },
  -- holds SpriteSet instances
  spritesets = { },
  
  -- holds nine patch textures
  ninePatchTextures = { }
}

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

function SpriteBank.registerSpriteRendererBuilder(key, builder)
  assert(not SpriteBank.builders[key], 'SpriteBank already has SpriteRendererBuilder with key ' .. key)
  SpriteBank.builders[key] = builder
end

function SpriteBank.build(key, entity)
  assert(SpriteBank.builders[key], 'SpriteBank does not have SpriteRendererBuilder with key ' .. key)
  return SpriteBank.builders[key]:build(entity)
end

function SpriteBank.registerSpriteset(spriteset)
  assert(spriteset:getName(), 'SpriteBank cannot register spriteset without a name')
  assert(not SpriteBank.spritesets[spriteset:getName()], 'SpriteBank already has spriteset with key ' .. spriteset:getName())
  SpriteBank.spritesets[spriteset:getName()] = spriteset
end

function SpriteBank.getSpriteset(key)
  assert(SpriteBank.spritesets[key], 'SpriteBank does not have a Spriteset with key ' .. key)
  return SpriteBank.spritesets[key]
end

function SpriteBank.registerNinePatchTexture(key, ninePatchTexture)
  assert(not SpriteBank.ninePatchTextures[key], 'SpriteBank already has nine patch texture with key ' .. key)
  SpriteBank.ninePatchTextures[key] = ninePatchTexture
end

function SpriteBank.getNinePatchTexture(key)
  assert(SpriteBank.ninePatchTextures[key], 'SpriteBank does not have nine patch texture with key ' .. key)
  return SpriteBank.ninePatchTextures[key]
end

--- create a nine patch sprite given a registed nine_patch_texture
--- NinePatchSprites are not cached due to the dynamic nature of their dimensions, so this always creates a new instance
---@param ninePatchTextureKey string
---@param width number?
---@param height number?
---@param alpha number?
---@return NinePatchSprite
function SpriteBank.createNinePatchSprite(ninePatchTextureKey, width, height, alpha)
  local spriteBuilder = SpriteBuilder()
  local ninePatchTexture = SpriteBank.getNinePatchTexture(ninePatchTextureKey)
  return spriteBuilder:buildNinePatchSprite(ninePatchTexture, width, height, alpha)
end

---@return SpriteRendererBuilder
function SpriteBank.createSpriteRendererBuilder()
  return SpriteRendererBuilder()
end

---@return SpriteAnimationBuilder
function SpriteBank.createSpriteAnimationBuilder()
  return SpriteAnimationBuilder()
end

---@return SpriteBuilder
function SpriteBank.createSpriteBuilder()
  return SpriteBuilder()
end

function SpriteBank.createSpriteset(spritesetName, sizeX, sizeY)
  return Spriteset(spritesetName, sizeX, sizeY)
end

---builds a NinePatchTexture
---adds it to the SpriteBank's ninePatchTextures if a key is provided
---@param spriteSheet SpriteSheet
---@param startX integer
---@param startY integer
---@return NinePatchTexture
function SpriteBank.createNinePatchTexture(spriteSheet, startX, startY, key)
  local ninePatchTexture = NinePatchTexture {
    spriteSheet:getTexture(startX, startY),
    spriteSheet:getTexture(startX + 1, startY),
    spriteSheet:getTexture(startX + 2, startY),
    spriteSheet:getTexture(startX, startY + 1),
    spriteSheet:getTexture(startX + 1, startY + 1),
    spriteSheet:getTexture(startX + 2, startY + 1),
    spriteSheet:getTexture(startX, startY + 2),
    spriteSheet:getTexture(startX + 1, startY + 2),
    spriteSheet:getTexture(startX + 2, startY + 2)
  }
  if key then
    SpriteBank.registerNinePatchTexture(key, ninePatchTexture)
  end
  return ninePatchTexture
end

--- builds a three patch texture as a nine patch texture, where the middle column
--- useful for textures that only need to stretch in one direction
--- @param spriteSheet SpriteSheet
--- @param startX integer
--- @param startY integer
--- @param horizontal boolean -- whether the three patch is horizontal (stretches in x direction) or vertical (stretches in y direction)
--- @param key string? -- optional key to register the nine patch texture in the SpriteBank
function SpriteBank.createThreePatchTextureAsNine(spriteSheet, startX, startY, horizontal, key)
  local ninePatchTexture
  if horizontal then
    -- 3 patches in a row: left | center | right  (stretches in X)
    local left   = spriteSheet:getTexture(startX,     startY)
    local center = spriteSheet:getTexture(startX + 1, startY)
    local right  = spriteSheet:getTexture(startX + 2, startY)

    local img = left.image
    local iw, ih = img:getDimensions()
    local lw = left:getDimensions()
    local cw = center:getDimensions()
    local rw = right:getDimensions()

    -- zero-height fillers preserve left/right widths so draw() gets correct leftW/rightW
    local emptyLeft   = Subtexture(img, love.graphics.newQuad(0, 0, lw, 0, iw, ih))
    local emptyCenter = Subtexture(img, love.graphics.newQuad(0, 0, cw, 0, iw, ih))
    local emptyRight  = Subtexture(img, love.graphics.newQuad(0, 0, rw, 0, iw, ih))

    ninePatchTexture = NinePatchTexture {
      emptyLeft, emptyCenter, emptyRight,  -- row 1: zero height
      left,      center,      right,       -- row 2: actual patches
      emptyLeft, emptyCenter, emptyRight,  -- row 3: zero height
    }
  else
    -- 3 patches in a column: top / center / bottom  (stretches in Y)
    local top    = spriteSheet:getTexture(startX, startY)
    local center = spriteSheet:getTexture(startX, startY + 1)
    local bottom = spriteSheet:getTexture(startX, startY + 2)

    local img = top.image
    local iw, ih = img:getDimensions()
    local th = select(2, top:getDimensions())
    local ch = select(2, center:getDimensions())
    local bh = select(2, bottom:getDimensions())

    -- zero-width fillers preserve top/bottom heights so draw() gets correct topH/bottomH
    local emptyTop    = Subtexture(img, love.graphics.newQuad(0, 0, 0, th, iw, ih))
    local emptyCenter = Subtexture(img, love.graphics.newQuad(0, 0, 0, ch, iw, ih))
    local emptyBottom = Subtexture(img, love.graphics.newQuad(0, 0, 0, bh, iw, ih))

    ninePatchTexture = NinePatchTexture {
      emptyTop,    top,    emptyTop,     -- row 1: zero-width edges, actual top
      emptyCenter, center, emptyCenter, -- row 2: zero-width edges, actual center
      emptyBottom, bottom, emptyBottom, -- row 3: zero-width edges, actual bottom
    }
  end

  if key then
    SpriteBank.registerNinePatchTexture(key, ninePatchTexture)
  end
  return ninePatchTexture
end


function SpriteBank.initialize(path)
  path = path or 'data.sprites'
  require(path)(SpriteBank)
end

function SpriteBank.unload()
  SpriteBank.builders = { }

  for _, spriteset in pairs(SpriteBank.spritesets) do
    spriteset:release()
  end
  SpriteBank.spritesets = { }

  for _, animation in ipairs(SpriteBank.animations) do
    animation:release()
  end

  for _, sprite in pairs(SpriteBank.sprites) do
    sprite:release()
  end

  SpriteBank.sprites = { }
end

return SpriteBank