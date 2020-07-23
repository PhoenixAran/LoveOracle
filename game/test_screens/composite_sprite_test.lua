local Class = require 'lib.class'
local TestEntity = require 'game.test_player'
local SpriteRenderer = require 'game.components.sprite_renderer'
local SpriteSheet = require 'game.graphics.sprite_sheet'
local Sprite = require 'game.graphics.sprite'
local CompositeSprite = require 'game.graphics.composite_sprite'

local CompositeSpriteTest = Class {
  init = function(self)
    self.testEntity = nil
    self.compositeSprite = nil
  end
}

function CompositeSpriteTest:enter(previous, ...)
  local spriteSheet = SpriteSheet(assets.images.entities.player, 16, 16, 1, 1)
  local sprites = { }
  sprites[#sprites + 1] = Sprite(spriteSheet:getTexture(20, 5), 0, 0)
  sprites[#sprites + 1] = Sprite(spriteSheet:getTexture(20, 6), 0, -16)
  self.compositeSprite = CompositeSprite(sprites)
  self.testEntity = TestEntity()
  self.testEntity:add(SpriteRenderer(self.compositeSprite))
end

function CompositeSpriteTest:update(dt)
  self.testEntity:update(dt)
end

function CompositeSpriteTest:draw()
  self.testEntity:draw()
  self.testEntity:debugDraw()
end

return CompositeSpriteTest