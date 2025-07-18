local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local lume = require 'lib.lume'

---manages 'flashing' of sprite renderers and animated sprite renderers
---@class SpriteFlasher
---@field tick integer
---@field duration integer
---@field isActive boolean
---@field alpha number
---@field sprites SpriteRenderer[]
local SpriteFlasher = Class { __includes = Component,
  init = function(self, entity, args)
    if args == nil then
      args = { }
    end
    Component.init(self, entity, args)
    if args.alpha == nil then
      args.alpha = 0.5
    end
    self.tick = 0
    self.duration = 0
    self.isActive = false
    self.alpha = 0.5
    self.sprites = args.sprites or { }
  end
}

function SpriteFlasher:getType()
  return 'sprite_flasher'
end

---@param value number
function SpriteFlasher:setAlpha(value)
  self.alpha = value
end

---@param spriteRenderer SpriteRenderer
function SpriteFlasher:addSprite(spriteRenderer)
  lume.push(self.sprites, spriteRenderer)
end

---@param spriteRenderer SpriteRenderer
function SpriteFlasher:removeSprite(spriteRenderer)
  lume.remove(self.sprites, spriteRenderer)
end

---@param duration integer
function SpriteFlasher:flash(duration)
  self.isActive = true
  self.tick = 0
  self.duration = duration
  lume.each(self.sprites, 'setAlpha', self.alpha)
end

function SpriteFlasher:stop()
  self.isActive = true
  self.tick = 0
  self.duration = 0
  lume.each(self.sprites, 'setAlpha', 1)
end

function SpriteFlasher:update()
  if self.isActive then
    if self.tick <= self.duration then
      self.tick = self.tick + 1
    else
      self.isActive = false
      self.tick = 0
      self.duration = 0
      lume.each(self.sprites, 'setAlpha', 1)
    end
  end
end

return SpriteFlasher