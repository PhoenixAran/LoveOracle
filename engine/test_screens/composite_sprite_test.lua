local Class = require 'lib.class'
local BaseScreen = require 'engine.base_screen'
local TestEntity = require 'engine.test_game_entity'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local SpriteSheet = require 'engine.graphics.sprite_sheet'
local Sprite = require 'engine.graphics.sprite'
local CompositeSprite = require 'engine.graphics.composite_sprite'

local CompositeSpriteTest = Class { __includes = BaseScreen,
  init = function(self)
    self.testEntity = nil
    self.compositeSprite = nil
  end
}

function CompositeSpriteTest:enter(previous, ...)
  local spriteSheet = assetManager.getSpriteSheet('player')
  local sprites = { }
  sprites[#sprites + 1] = Sprite(spriteSheet:getTexture(21, 6), 0, 0)
  sprites[#sprites + 1] = Sprite(spriteSheet:getTexture(21, 7), 0, -16)
  self.compositeSprite = CompositeSprite(sprites, 8, 24)
  self.testEntity = TestEntity()
  self.testEntity:add(SpriteRenderer(self.compositeSprite))
  self.testEntity:add(SpriteRenderer(Sprite(spriteSheet:getTexture(21, 6)), 18, 0))
  self.testEntity:add(SpriteRenderer(Sprite(spriteSheet:getTexture(21, 7)), 18, -16))
  
  self.testEntity:awake()
end

function CompositeSpriteTest:update(dt)
  self.testEntity:update(dt)
end

function CompositeSpriteTest:draw()
  self.testEntity:draw()
  self.testEntity:debugDraw()
end

return CompositeSpriteTest