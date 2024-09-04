local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local vector = require 'engine.math.vector'
local Direction4  = require 'engine.enums.direction4'
local Physics = require 'engine.physics'
local bit = require 'bit'

local function queryTileFilter(item)
  if item.isTile and item:isTile() and item:isTopTile() then
    return true
  end
  return false
end

---@class PlayerLedgeJumpState : PlayerState
---@field velocityX number
---@field velocityY number
---@field hasRoomChanged boolean
---@field direction4 Direction4
---@field landingPositionX number
---@field landingPositionY number
---@field _playerBumpBox table
local PlayerLedgeJumpState = Class { __includes = PlayerState,
  init = function(self)
    PlayerState.init(self)


    self.stateParameters.canAutoRoomTransition = true
    self.stateParameters.canStrafe = true

    self.stateParameters.canWarp = false
    self.stateParameters.canControlOnGround = false
    self.stateParameters.canControlInAir = false
    self.stateParameters.canUseWeapons = false
    self.stateParameters.canReleaseSword = false
    self.stateParameters.canUseWeapons = false

    self._playerBumpBox = { }
    self.oldCollisionLayer = 0
  end
}

function PlayerLedgeJumpState:getType()
  return 'player_ledge_jump_state'
end

function PlayerLedgeJumpState:getLandingPosition(posX, posY)
  local moveVectorX, moveVectorY = Direction4.getVector(self.direction4)
  local landingPositionX, landingPositionY = vector.add(posX, posY, vector.mul(4, moveVectorX, moveVectorY))
  while not self:canLandAtPosition(landingPositionX, landingPositionY) do
    landingPositionX, landingPositionY = vector.add(landingPositionX, landingPositionY, moveVectorX, moveVectorY)
  end
  landingPositionX, landingPositionY = vector.add(landingPositionX, landingPositionY, moveVectorX, moveVectorY)
  return landingPositionX, landingPositionY
end

function PlayerLedgeJumpState:canLandAtPosition(x, y)
  local player = self.player
  local items, len = Physics:queryRect(player.x, player.y, player.w, player.h, queryTileFilter)
  for _, tile in ipairs(items) do
    -- we cannot land on hazard tiles or tiles that player considers solid
    if tile:isHazardTile() or bit.band(tile.tileType, player.collisionTiles) ~= 0 then
      -- TODO allow landing on solid tiles if we can break them? (idk)
      return false
    end
  end
  Physics.freeTable(items)
  return true
end

function PlayerLedgeJumpState:onBegin(previousState)
  self.player:stopPushing()
  --temporarily disable solid collisions
  self.oldCollisionLayer = self.player:getPhysicsLayer()
  self.player:setPhysicsLayerExplicit(0)

  if not self.player.stateParameters.canStrafe then
    self.player:setAnimationDirection4(self.direction4)
  end

  self.landingPositionX, self.landingPositionY = self:getLandingPosition(self.player.getPosition())

  
end

function PlayerLedgeJumpState:onEnterRoom()
  -- TODO
end

function PlayerLedgeJumpState:onEnd(newState)
  --reenable collisions
  self.player:setPhysicsLayerExplicit(self.oldCollisionLayer)
  self.oldCollisionLayer = 0


end

function PlayerLedgeJumpState:update(dt)
  
end

return PlayerLedgeJumpState
