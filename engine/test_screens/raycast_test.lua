local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local BaseScreen = require 'engine.screens.base_screen'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local lume = require 'lib.lume'
local bit = require 'bit'
local Physics = require 'engine.physics'
local AssetManager = require 'engine.utils.asset_manager'
local Slab = require 'lib.slab'


local TestBox = Class { __includes = Entity,
  init = function(self, name, rect, zRange)
    Entity.init(self, true, true, name, rect, zRange)
  end
}

local RaycastTestScreen = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.testBoxes = { }
    self.hits = { }
    self.clickCount = 0
    self.physicsDetectLayer = 0

    self.startX, self.startY = 0, 0
    self.endX, self.endY = 0, 0
  end
}

function RaycastTestScreen:enter(prev, ...)
  Physics.reset()
  -- this test box will be in the same range as the test raycast
  lume.push(self.testBoxes, TestBox( 'testbox1', {x = 24, y = 24, w = 24, h = 24}, {min = 20, max = 30}))
  -- this test box will be 'under' the raycast
  lume.push(self.testBoxes, TestBox('testbox2', {x = 65, y = 40, w = 16, h = 12}, {min = -30, max = -4}))
  -- this test box will be 'above' the raycast
  lume.push(self.testBoxes, TestBox('testbox3', {x = 60, y = 16, w = 24, h = 21}, {min = 51, max = 200}))
  -- this test box will be in the same range as the test raycast, but not have the same physics bit flags
  lume.each(self.testBoxes, 'awake')

  monocle:resize(1280, 720)
end


function RaycastTestScreen:update(dt)
  Slab.Update(dt)
  for _, b in ipairs(self.testBoxes) do
    b:update(dt)
  end 


  -- update code here
  if Slab.IsVoidHovered() then
    if self.clickCount == 0 then
      if input:pressed('leftClick') then
        if self:mouseClickInGame() then
          self.startX, self.startY = self:getMousePositionInCanvas()
          self.clickCount = 1
        end
      end
    elseif self.clickCount == 1 then
      if input:pressed('leftClick') then
        if self:mouseClickInGame() then
          self.endX, self.endY = self:getMousePositionInCanvas()
          self.clickCount = 2
        end
      end
    end
  end
  Slab.BeginWindow('raycast-test-screen-instructions', { Title = 'Instructions'})
  if self.clickCount == 0 then
    Slab.Text('Click beginning point for raycast')
  elseif self.clickCount == 1 then
    Slab.Text('Click end point for raycast')
  else 
    Slab.Text('TODO report hits')
    if Slab.Button('Remake Raycast') then
      self.clickCount = 0
    end
  end
  Slab.EndWindow()
end


function RaycastTestScreen:draw()
  monocle:begin()
  for _, b in ipairs(self, testBoxes) do
    b:debugDraw()
  end 
  monocle:finish()
  Slab.Draw()
end

return RaycastTestScreen