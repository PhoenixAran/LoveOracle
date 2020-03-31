local class = require 'lib.class'
local push = require 'lib.push'
local quadHelper = require 'lib.quadhelper'
local Scene = require 'engine.scene'
local Sprite = require 'engine.graphics.sprite'
local Entity = require 'engine.entities.entity'
local vector2 = require 'lib.vec2'

local SpriteTest = class {
  __includes = Scene,
  init = function(self)
    self.sprite = nil
  end
}


function SpriteTest:load()
  local SpriteBuilder = require 'engine.graphics.sprite_builder'
  local sb = SpriteBuilder()
  self.sprite = Sprite(nil, 16, 16)
  self.sprite.image = love.graphics.newImage('player.png')
  sb:setSprite(self.sprite)
  sb:setQuadCollection(quadHelper.generateQuad(self.sprite.image, 16, 16, 1), 7, 29)

  --lets build walking :^]
  sb:setQuad(0, 6)
    :setDelay(6)
  sb:buildFrame()
  sb:setQuad(0, 7)
    :setDelay(6)
    :buildFrame()
  sb:setLooptype("cycle")
  sb:buildAnimation("walking")
  self.sprite:play("walking")
end

function SpriteTest:update(dt)
  self.sprite:update(dt)
end

function SpriteTest:draw()
  love.graphics.print("Sprite Test", 144 / 2 - 22, 0)
  self.sprite:draw()
end

return SpriteTest
