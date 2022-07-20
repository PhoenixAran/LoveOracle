local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local BaseScreen = require 'engine.screens.base_screen'
local Raycast = require 'engine.components.raycast'
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

local PlaceholderEntity = Class { __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)
    self:setPhysicsLayer('entity')
    self.raycast = Raycast(self, {
      castToY = 20
    })
  end
}

function PlaceholderEntity:debugDraw()
  self.raycast:debugDraw()
end

local RaycastDebugDrawTest = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)

  end
}

function RaycastDebugDrawTest:enter(prev, ...)
  self.placeholderEntity = PlaceholderEntity({
    x = 24,
    y = 24
  })
  self.placeholderEntity:initTransform()
end

function RaycastDebugDrawTest:update(dt)
  local raycast = self.placeholderEntity.raycast
  Slab.Update(dt)
  Slab.BeginWindow('raycast-vals', {Title = 'Raycast Config'})
  local castToX, castToY = raycast.castToX, raycast.castToY
  Slab.Text('X')
  if Slab.Input('x', {Text = castToX, NumbersOnly = true}) then
    castToX = Slab.GetInputNumber()
  end
  Slab.Text('Y')
  if Slab.Input('y', {Text = castToY, NumbersOnly = true}) then
    castToY = Slab.GetInputNumber()
  end
  raycast.castToX, raycast.castToY = castToX, castToY
  self.placeholderEntity:update(dt)
  Slab.EndWindow()
end

function RaycastDebugDrawTest:draw()
  Slab.Draw()
  monocle:begin()
  self.placeholderEntity:debugDraw()
  monocle:finish()
end

return RaycastDebugDrawTest