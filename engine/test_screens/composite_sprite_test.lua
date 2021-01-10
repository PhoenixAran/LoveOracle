local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
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
  local assetManager = require 'engine.utils.asset_manager'
  local spriteSheet = assetManager.getSpriteSheet('player')
  local sprites = { }
  sprites[#sprites + 1] = Sprite(spriteSheet:getTexture(21, 6), 0, 0)
  sprites[#sprites + 1] = Sprite(spriteSheet:getTexture(21, 7), 0, -16)
  self.compositeSprite = CompositeSprite(sprites, 8, 24)
  self.testEntity = TestEntity()
  -- s1 should display the same thing as s2 and s3
  self.testEntity['s1'] = SpriteRenderer(self.testEntity, self.compositeSprite)
  self.testEntity['s2'] = SpriteRenderer(self.testEntity, Sprite(spriteSheet:getTexture(21, 6)), 18, 0)
  self.testEntity['s3'] = SpriteRenderer(self.testEntity, Sprite(spriteSheet:getTexture(21, 7)), 18, -16)
  
  self.testEntity:awake()
end

function CompositeSpriteTest:update(dt)

end

function CompositeSpriteTest:draw()
  monocle:begin()
  self.testEntity['s1']:draw()
  self.testEntity['s2']:draw()
  self.testEntity['s3']:draw()
  monocle:finish()
end

return CompositeSpriteTest