local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local BumpBox = require 'engine.entities.bump_box'
local Transform = require 'engine.entities.transform'
local Vector = require 'engine.math.vector'
local rect = require 'engine.math.rectangle'
local InspectorProperties = require 'engine.entities.inspector_properties'
local EntityDrawType = require 'engine.enums.entity_draw_type'
local uuid = require 'engine.utils.uuid'
local Consts = require 'constants'
local Physics = require 'engine.physics'
local bit = require 'bit'
local EntityDebugDrawFlags = require('engine.enums.flags.entity_debug_draw_flags').enumMap


local GRID_SIZE = Consts.GRID_SIZE

---@class Entity : SignalObject, BumpBox
---@field enabled boolean
---@field visible boolean
---@field transform Transform
---@field name string
---@field onTransformChanged function
---@field onAwake function
---@field onRemoved function
---@field drawType EntityDrawType
---@field collisionTag string
local Entity = Class { __includes = { SignalObject, BumpBox },
  init = function(self, args)
    if args == nil then
      args = { }
    end

    SignalObject.init(self)
    self:signal('entity_destroyed')
    self:signal('spawned_entity')

    if args.enabled == nil then args.enabled = true end
    if args.visible == nil then args.visible = true end
    if args.x == nil then args.x = 0 end
    if args.y == nil then args.y = 0 end
    if args.w == nil then args.w = 1 end
    if args.h == nil then args.h = 1 end
    if args.drawType == nil then args.drawType = EntityDrawType.ySort end
    if args.useBumpCoords then
      BumpBox.init(self, args)
    else
      args.x = args.x - args.w / 2
      args.y = args.y - args.h / 2
      BumpBox.init(self, args)
    end
    self.enabled = args.enabled
    self.visible = args.visible
    self.drawType = args.drawType
    self.transform = Transform:new(self)
    self.name = args.name or uuid()
    self.collisionTag = args.collisionTag
  end
}

function Entity:getName()
  return self.name
end

function Entity:getType()
  return 'entity'
end

function Entity:getCollisionTag()
  return self.collisionTag
end

function Entity:isTile()
  return false
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

---called when transform is changed
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

---position of the transform relative to the parnet transform. If the transform has no parent, it is the same as the Transform
---@return number x
---@return number y
function Entity:getLocalPosition()
  local x, y, z = self.transform:getLocalPosition()
  return x, y
end

---gets z position
---@return number z
function Entity:getZPosition()
  local x, y, z = self.transform:getPosition()
  return z
end

---returns tile index this entity is on
---@return integer x
---@return integer y
function Entity:getTileIndex()
  local x, y = self:getPosition()
  return math.floor(x / GRID_SIZE), math.floor(y / GRID_SIZE)
end

---sets z position
---@param z number
function Entity:setZPosition(z)
  local x, y = self:getPosition()
  self.transform:setPosition(x, y, z)
end

---returns position
---@return number x
---@return number y
function Entity:getPosition()
  local x, y, z = self.transform:getPosition()
  return x, y
end

---sets entity position
---@param x any
---@param y any
---@param z any
function Entity:setPosition(x, y, z)
  if z == nil then z = self:getZPosition() end
  self.transform:setPosition(x, y, z)
end

---sets position via top left corner position
---@param x number
---@param y number
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

---sets local position
---@param x number
---@param y number
function Entity:setLocalPosition(x, y)
  self.transform:setLocalPosition(x, y)
end

---resizes entity
---@param width number
---@param height number
function Entity:resize(width, height)
  self.x, self.y, self.w, self.h = rect.resizeAroundCenter(self.x, self.y, self.w, self.h, width, height)
  Physics:update(self, self.x, self.y, self.w, self.h)
end

---adds given entity's transform as child
---@param entity any
function Entity:addChild(entity)
  entity.transform:setParent(self.transform)
end

---called when entity as added
---@param gameScreen any current scene
function Entity:added(gameScreen)

end

---called when the entity is awaken
function Entity:awake()
  if not self.registeredWithPhysics then
    Physics:add(self, self.x, self.y, self.w, self.h)
  end
  self:onAwake()
end

function Entity:onAwake()
  
end

---@return EntityDrawType
function Entity:getDrawType()
  return self.drawType
end

---called every frame interval
function Entity:update()

end

---draw method
function Entity:draw()

end

---called when the entity is removed
---@param scene any
function Entity:removed(scene)
  Physics:remove(self)
  self.registeredWithPhysics = false
  self.scene = nil
  if self.onRemoved then
    self:onRemoved(scene)
  end
end

function Entity:destroy()
  -- notify entity script so they can play their death sound
---@diagnostic disable-next-line: undefined-field
  if self.onDeath then
---@diagnostic disable-next-line: undefined-field
    self:onDeath()
  end
  self:emit('entity_destroyed', self)
  self:release()
end

function Entity:isInAir()
  return false
end

function Entity:isOnGround()
  return not self:isInAir()
end

---debug draw
---@param entDebugDrawFlags integer
function Entity:debugDraw(entDebugDrawFlags)
  if bit.band(entDebugDrawFlags, EntityDebugDrawFlags.BumpBox) ~= 0 then
    local positionX, positionY = self:getBumpPosition()
    love.graphics.setColor(0, 0, 160 / 225, 180 / 255)
    love.graphics.rectangle('line', positionX, positionY, self.w, self.h)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

---gets inspector properties object for entity inspector
---@return InspectorProperties
function Entity:getInspectorProperties()
  local props = InspectorProperties(self)
  props:setGroup('Entity')
  props:addReadOnlyString('Name', 'name')
  props:addVector2('Position', self.getPosition, self.setPosition)
  props:addVector2i('Size', self.getSize, self.resize)
  props:setGroup()
  return props
end

return Entity