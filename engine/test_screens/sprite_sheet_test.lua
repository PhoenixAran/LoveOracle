local Class = require 'lib.class'
local SpriteSheet = require 'engine.graphics.sprite_sheet'
local AssetManager = require 'engine.asset_manager'
local Singletons = require 'engine.singletons'
local DisplayHandler = require 'engine.display_handler'
local SpriteSheetTest = Class {
  init = function(self)
    self.testEntity = 3
    self.spriteSheet = nil
    self.currentIndex = 1
    self.maxIndex = 2
    self.upKeyReleased = false
    self.downKeyReleased = false
  end
}

function SpriteSheetTest:enter(previous, ...)
  self.spriteSheet = AssetManager.getSpriteSheet('player_items')
  self.maxIndex = self.spriteSheet:size()
end

function SpriteSheetTest:update()  
  if love.keyboard.isDown("up") and self.upKeyReleased then
    if self.currentIndex < self.maxIndex then
      self.currentIndex = self.currentIndex + 1
    end
  elseif love.keyboard.isDown("down") and self.downKeyReleased then
    if self.currentIndex > 1 then
      self.currentIndex = self.currentIndex - 1
    end
  end
  self.upKeyReleased = not love.keyboard.isDown("up")
  self.downKeyReleased = not love.keyboard.isDown("down")
end

function SpriteSheetTest:draw()
  DisplayHandler.push()
  local subtexture = self.spriteSheet:getTexture(self.currentIndex)
  love.graphics.draw(subtexture.image, subtexture.quad, 160 / 2, 144 / 2)
  love.graphics.setColor(0, 70 / 255, 120 / 255, 255 / 255)
  love.graphics.rectangle("line", (160 / 2) - 1, (144 / 2) - 1, 18, 18)
  love.graphics.setColor(1, 1, 1)
  DisplayHandler.pop()
end

return SpriteSheetTest