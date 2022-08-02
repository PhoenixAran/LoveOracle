local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local BaseScreen = require 'engine.screens.base_screen'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local lume = require 'lib.lume'
local bit = require 'bit'
local Physics = require 'engine.physics'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local AssetManager = require 'engine.utils.asset_manager'
local Slab = require 'lib.slab'

local Singletons = require 'engine.singletons'
local monocle = Singletons.monocle
local input = Singletons.input

local TestBox = Class { __includes = Entity,
  --init = function(self, name, rect, zRange)
  init = function(self, args)
    Entity.init(self, args)
    self:setPhysicsLayer('entity')
  end
}

local RaycastTestScreen = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.testBoxes = { }
    self.hits = { }
    self.clickCount = 0
    self.physicsDetectLayer = PhysicsFlags:get('entity').value
    self.startX, self.startY = 0, 0
    self.endX, self.endY = 0, 0
  end
}

function RaycastTestScreen:enter(prev, ...)
  -- this test box will be in the same range as the test raycast
  lume.push(self.testBoxes, TestBox( {name = 'testbox1', x = 24, y = 24, w = 24, h = 24, zMin = 20, zMax = 30}))
  -- this test box will be 'under' the raycast
  lume.push(self.testBoxes, TestBox({name = 'testbox2', x = 65, y = 40, w = 16, h = 12, zMin = -30, zMax = -4}))
  -- this test box will be 'above' the raycast
  lume.push(self.testBoxes, TestBox({name = 'testbox3', x = 70, y = 80, w = 24, h = 21, zMin = 101, zMax = 200}))
  lume.each(self.testBoxes, 'awake')
  monocle:resize(1280, 720)
end

local function zFilter(item)
  return item.zRange.max > -100 and item.zRange.min < 100
end

function RaycastTestScreen:update(dt)
  input:update(dt)
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
    -- report hits
    lume.clear(self.hits)
    local items, len = Physics:querySegment(self.startX, self.startY, self.endX, self.endY, zFilter)
    Slab.Text('Start: ( ' .. self.startX .. ' , ' .. self.startY .. ' )')
    Slab.Text('End: ( ' .. self.endX .. ' , ' .. self.endY .. ' )')
    Slab.Text('Hits: ' .. len)
      
    for i, box in ipairs(self.hits) do
      Slab.Text(tostring(i) .. '. ' .. tostring(box))
    end
    if Slab.Button('Remake Raycast') then
      self.clickCount = 0
    end
    Physics.freeTable(items)
  end
  Slab.EndWindow()
end


function RaycastTestScreen:draw()
  monocle:begin()
  for _, b in ipairs(self.testBoxes) do
    b:debugDraw()
  end 
  if self.clickCount == 2 then
    love.graphics.setColor(.52, 0, .80)
    love.graphics.line(self.startX, self.startY, self.endX, self.endY)
    love.graphics.setColor(0, 0, 0)
  end
  monocle:finish()
  Slab.Draw()
end

return RaycastTestScreen