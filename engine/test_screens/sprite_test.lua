local Class = require 'lib.class'
local TestEntity = require 'engine.test_screens.test_game_entity'
local Sprite = require 'engine.graphics.sprite'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local Subtexture = require 'engine.graphics.subtexture'
local AssetManager = require 'engine.asset_manager'
local Singletons = require 'engine.singletons'
local DisplayHandler = require 'engine.display_handler'
local SpriteTest = Class {
  init = function(self)
    self.testEntity = nil
  end
}

function SpriteTest:enter(previous, ...)
  self.testEntity = TestEntity()
  local image = AssetManager.getImage('player')
  local quad = love.graphics.newQuad( 103, 1, 16, 16, image:getWidth(), image:getHeight())
  local subtexture = Subtexture(image, quad)
  local sprite = Sprite(subtexture, 16, 16)
  local spriteRenderer = SpriteRenderer(self.testEntity, sprite, -16, -16)
  self.testEntity['sr'] = (spriteRenderer)
end


function SpriteTest:draw()
  DisplayHandler.push()
  self.testEntity['sr']:draw()
  self.testEntity:debugDraw()
  DisplayHandler.pop()
end

return SpriteTest