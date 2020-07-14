local Class = require 'lib.class'
local TestEntity = require 'game.test_player'
local Sprite = require 'game.graphics.sprite'
local SpriteRenderer = require 'game.components.sprite_renderer'
local Subtexture = require 'game.graphics.subtexture'


local SpriteTest = Class {
  init = function(self)
    self.testEntity = nil
  end
}

function SpriteTest:enter(previous, ...)
  self.testEntity = TestEntity()
  local image = love.graphics.newImage("assets/images/entities/player.png")
  local quad = love.graphics.newQuad( 103, 1, 16, 16, image:getWidth(), image:getHeight())
  local subtexture = Subtexture(image, quad)
  local sprite = Sprite(subtexture)
  local spriteRenderer = SpriteRenderer(sprite)
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