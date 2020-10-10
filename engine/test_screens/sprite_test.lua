local Class = require 'lib.class'
local TestEntity = require 'engine.test_game_entity'
local Sprite = require 'engine.graphics.sprite'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local Subtexture = require 'engine.graphics.subtexture'


local SpriteTest = Class {
  init = function(self)
    self.testEntity = nil
  end
}

function SpriteTest:enter(previous, ...)
  self.testEntity = TestEntity()
  local image = assetManager.getImage('player')
  local quad = love.graphics.newQuad( 103, 1, 16, 16, image:getWidth(), image:getHeight())
  local subtexture = Subtexture(image, quad)
  local sprite = Sprite(subtexture, 16, 16)
  local spriteRenderer = SpriteRenderer(sprite, -16, -16)
  self.testEntity:add(spriteRenderer)
end

function SpriteTest:update(dt)
  self.testEntity:update(dt)
end

function SpriteTest:draw()
  self.testEntity:draw()
  self.testEntity:debugDraw()
end

return SpriteTest