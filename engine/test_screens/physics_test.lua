local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local TestEntity = require 'engine.test_game_entity'
local BaseScreen = require 'engine.screens.base_screen'
local lume = require 'lib.lume'
local bit = require 'bit'
local Physics = require 'engine.physics'


local TestBox = Class { __includes = Entity,
  init = function(self, name, rect, zRange)
    Entity.init(self, true, true, name, rect, zRange)
    self:setPhysicsLayer('entity')
  end
}

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
  
  -- set range to 0, 50 for test player
  self.testEntity:setZRange(0, 50)

  -- this test box will be in the same range as the player
  lume.push(self.testBoxes, TestBox( 'testbox1', {x = 24, y = 24, w = 24, h = 24}, {min = 20, max = 30}))

  -- this test box will be 'under' the player
  lume.push(self.testBoxes, TestBox('testbox2', {x = 65, y = 40, w = 16, h = 12}, {min = -30, max = -4}))

  -- this test box will be 'above' the player
  lume.push(self.testBoxes, TestBox('testbox3', {x = 60, y = 16, w = 24, h = 21}, {min = 51, max = 200}))
  
  lume.each(self.testBoxes, 'awake')
end

function Screen:update(dt)
  for _, b in ipairs(self.testBoxes) do
    b:update(dt)
  end
  self.testEntity:update(dt)
end

function Screen:draw()
  monocle:begin()
  for _, b in ipairs(self.testBoxes) do
    b:debugDraw()
  end
  self.testEntity:debugDraw()
  monocle:finish()
end

return Screen