local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local BumpBox = require 'engine.entities.bump_box'
local Transform = require 'engine.entities.transform'
local Vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local InspectorProperties = require 'engine.entities.inspector_properties'

local Physics = require 'engine.physics'

local Entity = Class { __includes = { SignalObject, BumpBox },
  init = function(self, args)
    if args == nil then
      args = { }
    end
    SignalObject.init(self)
    if args.enabled == nil then args.enabled = true end
    if args.visible == nil then args.visible = true end
    if args.x == nil then args.x = 0 end
    if args.y == nil then args.y = 0 end
    if args.w == nil then args.w = 1 end
    if args.h == nil then args.h = 1 end
    if args.useBumpCoords then
      BumpBox.init(self, args)
    else
      args.x = args.x - args.w / 2
      args.y = args.y - args.h / 2
      BumpBox.init(self, args)
    end
    self.enabled = args.enabled
    self.visible = args.visible
    self.transform = Transform:new(self)
    self.name = args.name
  end
}

function Entity:getName()
end

function Entity:getType()
  return 'entity'
end

function Entity:isTile()
  return false
end

function Entity:getCollisionTag()
  return 'entity'
end

function Entity:setVisible(value)
  self.visible = value
end

function Entity:isVisible()
  return self.visible
end

function Entity:setEnabled(value)
  self.enabled = value
end

function Entity:isEnabled()
  return self.enabled
end

-- position and transform stuff
function Entity:transformChanged()
  local ex, ey = self:getPosition()
  -- need to manually calculate it because Entity:setPositionWithBumpCoords
  -- will trigger transform:change which will cause in infinite loop
  self.x = ex - self.w / 2
  self.y = ey - self.h / 2
  if self.onTransformChanged then
    self:onTransformChanged()
  end
end

function Entity:getLocalPosition()
  local x, y, z = self.transform:getLocalPosition()
  return x, y
end

function Entity:getZPosition()
  local x, y, z = self.transform:getPosition()
  return z
end

function Entity:setZPosition(z)
  local x, y = self:getPosition()
  self.transform:setPosition(x, y, z)
end

function Entity:getPosition()
  local x, y, z = self.transform:getPosition()
  return x, y
end

function Entity:setPosition(x, y, z)
  if z == nil then z = self:getZPosition() end
  self.transform:setPosition(x, y, z)
end

function Entity:setPositionWithBumpCoords(x, y)
  self.transform:setPosition(x + self.w / 2, y + self.h / 2)
end

-- call this after each constructor
-- this is due to some thing:onTransformChanged code being called
-- before their components are initialized (see item_sword)
-- to get around this, just call this function after creating an entity
function Entity:initTransform()
  self:setPositionWithBumpCoords(self.x, self.y)
  self.transform:setRotation(0)
end

function Entity:setLocalPosition(x, y)
  self.transform:setLocalPosition(x, y)
end

function Entity:resize(width, height)
  Physics.remove(self)
  self.x, self.y, self.w, self.h = rect.resizeAroundCenter(self.x, self.y, self.w, self.h, width, height)
  Physics.add(self)
end

function Entity:addChild(entity)
  entity.transform:setParent(self.transform)
end

-- gameloop callbacks
function Entity:added(gameScreen)

end

function Entity:awake()
  Physics.add(self)
  self.registeredWithPhysics = true
  if self.onAwake then
    self:onAwake()
  end
end

function Entity:update(dt)

end

function Entity:draw()

end

function Entity:removed(scene)
  Physics.remove(self)
  self.registeredWithPhysics = false
  self.scene = nil
  if self.onRemoved then
    self:onRemoved(scene)
  end
end

function Entity:debugDraw()
  --love draws from the upper left corner so we use our bump coordinates
  local positionX, positionY = self:getBumpPosition()
  love.graphics.setColor(0, 0, 160 / 225, 180 / 255)
  love.graphics.rectangle('fill', positionX, positionY, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
end

function Entity:getInspectorProperties()
  local props = InspectorProperties(self)
  props:addReadOnlyString('Name', 'name')
  props:addVector2('Position', self.getPosition, self.setPosition)
  props:addVector2i('Size', self.getSize, self.resize)
  return props
end

return Entity