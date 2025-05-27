local Class = require 'lib.class'
local lume = require 'lib.lume'
local Component = require 'engine.entities.component'
local Tween = require 'lib.tween'


local Y_SCALE_FACTOR = 0.1

local WiggleState = {
  Smaller = 1,
  Bigger = 2
}

---@class SpriteSquisher : Component
---@field spriteRenderers SpriteRenderer[]
---@field spriteScale number
---@field _originalSpriteScale number
---@field tween any? tween instance
---@field wiggleState integer
local SpriteSquisher = Class { __includes = Component,
  ---@param self SpriteSquisher
  ---@param args table
  init = function(self, entity, args)
    args = args or {}
    Component.init(self, entity, args)
    self.spriteScale = args.spriteScale or 1
    self.spriteRenderers = { }
    self._originalSpriteScale = self.spriteScale
    self.tween = nil
    self.wiggleState = WiggleState.Smaller
  end
}

--- Adds a sprite renderer to the list of renderers affected by the wiggler.
---@param spriteRenderer SpriteRenderer
function SpriteSquisher:addSpriteRenderer(spriteRenderer)
  lume.push(self.spriteRenderers, spriteRenderer)
end

--- Remove spriteRenderer
---@param spriteRenderer SpriteRenderer
function SpriteSquisher:removeSpriteRenderer(spriteRenderer)
  lume.remove(self.spriteRenderers, spriteRenderer)
end

-- TODO add wiggle types
function SpriteSquisher:wiggle(duration, yScale)
  if yScale == nil then
    yScale = Y_SCALE_FACTOR
  end
  self.duration = duration
  self.wiggleState = WiggleState.Smaller
  self.tween = Tween.new(duration, self, { spriteScale = self.spriteScale - yScale }, 'inOutCubic')
end

function SpriteSquisher:update()
  if self.tween then
    if self.wiggleState == WiggleState.Smaller then
      if self.tween:update(love.time.dt) then
        self.wiggleState = WiggleState.Bigger
        self.tween = Tween.new(self.duration, self, { spriteScale = self._originalSpriteScale }, 'inOutCubic')
      end
    else
      if self.tween:update(love.time.dt) then
        self.wiggleState = WiggleState.Smaller
        self.tween = nil
        self.spriteScale = self._originalSpriteScale
      end
    end
    lume.each(self.spriteRenderers, 'setScaleY', self.spriteScale)
  end
end

function SpriteSquisher:getType()
  return 'sprite_squisher'
end

return SpriteSquisher