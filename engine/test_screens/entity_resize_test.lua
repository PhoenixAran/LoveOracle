local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local TestEntity = require 'engine.test_game_entity'
local BaseScreen = require 'engine.screens.base_screen'

local Physics = require 'engine.physics'

local TestBox = Class { __includes = Entity,
  init = function(self, rect)
    Entity.init(self, true, true, rect)
    self:setPhysicsLayer('entity')
  end
}

function TestBox:entityAwake()
  Physics.add(self)
end

-- experiental physics test screen
local Screen = Class { __includes = BaseScreen,
  init = function(self)
    self.testEntity = nil
    self.testBoxes = { }
  end
}

function Screen:enter(prev, ...)
  Physics.reset()
  self.testEntity = TestEntity()
  self.testEntity:setCollidesWithLayer('entity')
  self.testEntity:awake()
  self.testBoxes[#self.testBoxes+ 1] = TestBox({x = 24, y = 24, w = 24, h = 24})
  self.testBoxes[#self.testBoxes]:entityAwake()
end

function Screen:update(dt)
  if love.keyboard.isDown('i') then
    self.testEntity:resize(32, 32)
  end  
  if love.keyboard.isDown('k') then
    self.testEntity:resize(32, 32)
  end
  if love.keyboard.isDown('j') then
    self.testEntity:resize(32, 16)
  end
  if love.keyboard.isDown('l') then
    self.testEntity:resize(16, 32)
  end
  if love.keyboard.isDown('n') then
    self.testEntity:resize(16, 16)
  end
  
  for _, b in ipairs(self.testBoxes) do
    b:update(dt)
  end
  self.testEntity:update(dt)
end

function Screen:draw()
  monocle:begin()
  for _, b in ipairs(self.testBoxes) do
    b:draw()
    b:debugDraw()
  end
  self.testEntity:draw()
  self.testEntity:debugDraw()
  monocle:finish()
end

return Screen