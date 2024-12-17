local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local Physics = require 'engine.physics'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local TablePool = require 'engine.utils.table_pool'
local vector = require 'engine.math.vector'
local lume = require 'lib.lume'

local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'

---@class LedgeJump : Entity
---@field direction4 integer
local LedgeJump = Class { __includes = Entity,
  init = function(self, args)
    args.w = args.width
    args.h = args.height
    args.useBumpCoords = true
    Entity.init(self, args)

    self:setPhysicsLayer('ledge_jump')
    self.direction4 = Direction4[args.direction]
  end
}

function LedgeJump:getType()
  return 'ledge_jump'
end

function LedgeJump:getCollisionTag()
  return 'ledge_jump'
end

function LedgeJump:getDirection4()
  return self.direction4
end

---comment
---@param x number xposition of ledge jumper
---@param y number yposition of ledge jumper
---@param dir8 Direction8
function LedgeJump:canLedgeJump(x, y, dir8)
  -- check if they are coming from the same direction
  if self:_validApproach(x, y) then
    -- check if they are facing the right way
    local doLedgeJump = false
    local dir4 = self:getDirection4()
    if dir4 == Direction4.up then
      doLedgeJump = dir8 == Direction8.up or dir8 == Direction8.upLeft or dir8 == Direction8.upRight
        or dir8 == Direction8.left or dir8 == Direction8.right -- allow these for slight angles on analogs
    elseif dir4 == Direction4.down then
      doLedgeJump = dir8 == Direction8.down or dir8 == Direction8.downLeft or dir8 == Direction8.downRight
        or dir8 == Direction8.left or dir8 == Direction8.right
    elseif dir4 == Direction4.left then
      doLedgeJump = dir8 == Direction8.left or dir8 == Direction8.upLeft or dir8 == Direction8.downLeft
        or dir8 == Direction8.up or dir8 == Direction8.down
    elseif dir4 == Direction4.right then
      doLedgeJump = dir8 == Direction8.right or dir8 == Direction8.upRight or dir8 == Direction8.downRight
        or dir8 == Direction8.up or dir8 == Direction8.down
    else
      error('Invalid ledge jump direction')
    end
    return doLedgeJump
  end
  return false
end

--- only allow ledge jump if entity is coming from the right direction
--- down = player must be coming from above
--- left = player must be coming from the right
--- and so on
---@param x any
---@param y any
---@return boolean
function LedgeJump:_validApproach(x, y)
  print(x, y, self:getPosition())
  local ex, ey = self:getPosition()
  local diffX, diffY = vector.sub(x, y, ex, ey)
  local approachDir4 = Direction4.getDirection(diffX, diffY)
  print(Direction4.debugString(approachDir4))
  return true
end

function LedgeJump:draw()
  -- love.graphics.setColor(1, 0, 0, .25)
  -- love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  -- love.graphics.setColor(1, 0, 0, .45)
  -- love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
  -- love.graphics.setColor(1, 1, 1)
end

return LedgeJump