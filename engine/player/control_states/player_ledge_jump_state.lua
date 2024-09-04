local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local vector = require 'engine.math.vector'
local Direction4  = require 'engine.enums.direction4'
local Physics = require 'engine.physics'
local bit = require 'bit'
local Singletons = require 'engine.singletons'
local Constants = require 'constants'
local tick = require 'lib.tick'

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
---@field ledgeJumpExtendsToNextRoom boolean
---@field _playerBumpBox table
---@field _playerMoveFilter function
---@field _playerRoomEdgeCollisionBoxMoveFilter function
local PlayerLedgeJumpState = Class { __includes = PlayerState,
  init = function(self)
    PlayerState.init(self)


    self.stateParameters.canAutoRoomTransition = true
    self.stateParameters.canStrafe = true

    self.stateParameters.canWarp = false
    self.stateParameters.canJump = false
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
  local pw, ph = player.w, player.h
  local px = x - (pw / 2)
  local py = y - (ph / 2)
  local items, len = Physics:queryRect(px,py,pw,ph,queryTileFilter)
  for _, tile in ipairs(items) do
    -- we cannot land on hazard tiles or tiles that player considers solid
    if bit.band(tile:getTileData().tileType, player.collisionTiles) ~= 0 then
      -- TODO allow landing on solid tiles if we can break them? (idk)
      return false
    end
  end
  Physics.freeTable(items)
  return true
end

function PlayerLedgeJumpState:onBegin(previousState)
  -- cancel pushing since ledges are usually inline with walls
  self.player:stopPushing()
  --temporarily disable solid collisions by niling out moveFilter and roomEdgeCollisionBoxMoveFilter
  self._playerMoveFilter = self.player.moveFilter
  self._playerRoomEdgeCollisionBoxMoveFilter = self.player.roomEdgeCollisionBoxMoveFilter
  local tempMoveFilter = function(item) return false end
  self.player.moveFilter = tempMoveFilter
  self.player.roomEdgeCollisionBoxMoveFilter = tempMoveFilter

  if not self.player.stateParameters.canStrafe then
    self.player:setAnimationDirection4(self.direction4)
  end

  self.player.sprite:play('jump')

  local px, py = self.player:getPosition()
  self.landingPositionX, self.landingPositionY = self:getLandingPosition(px, py)

  local roomControl = Singletons.gameControl:getRoomControl()
  if not roomControl:inRoomBounds(px, py) then
    self.ledgeJumpExtendsToNextRoom = true
    self.hasRoomChanged = false
    self.velocityX = 0
    self.velocityY = -1
    self.player:setZVelocity(0)
  else
    --Determine the jump speed based on the distance needed to move
    --Smaller ledge distances have slower jump speeds
    local direction4VectorX, direction4VectorY = Direction4.getVector(self.direction4)
    local tx, ty = vector.sub(self.landingPositionX, self.landingPositionY, px, py)
    local distance = vector.dot(tx, ty, direction4VectorX, direction4VectorY)
    local jumpSpeed = 1.5
    if distance >= 28 then
      jumpSpeed = 2.0
    elseif distance >= 20 then
      jumpSpeed = 1.75
    end

    -- calculate the movement speed based on jump speed
    local jumpTime = (2.0 / jumpSpeed) / Constants.DEFAULT_GRAVITY / tick.rate
    local speed = distance / jumpTime

    -- for longer ledge distances, calculate the speed so that both
    -- the movement speed and the jump speed equal eachother
    if speed > 1.5 then
      speed = math.sqrt(0.5 * distance * Constants.DEFAULT_GRAVITY)
      jumpSpeed = speed
    end

    self.velocityX, self.velocityY = vector.mul(speed, direction4VectorX, direction4VectorY)
    self.player.movement.gravity = 8  -- TODO remove this magic number
    self.player:setZVelocity(jumpSpeed)
    self.ledgeJumpExtendsToNextRoom = false
  end
  local newX, newY = vector.add(self.velocityX, self.velocityY, self.player:getPosition())
  self.player:setPosition(newX, newY)
  Physics:update(self.player, self.player:getBumpPosition())
end

function PlayerLedgeJumpState:onEnd(newState)
  --reenable collisions
  self.player.moveFilter = self._playerMoveFilter
  self.player.roomEdgeCollisionBoxMoveFilter = self._playerRoomEdgeCollisionBoxMoveFilter 

  self.player:setVector(0, 0)
  -- todo player:landOnSurface()
  if self.ledgeJumpExtendsToNextRoom then
    self.player:markRespawn()
  end
end

function PlayerLedgeJumpState:onEnterRoom()
  if self.ledgeJumpExtendsToNextRoom then
    self.hasRoomChanged = true

    self.landingPositionX, self.landingPositionY = self:getLandingPosition(self.player:getPosition())

    -- move the player to be at the landing spot, and raise it's z position
    -- so that it falls onto the landing spot
    local px, py = self.player:getPosition()
    self.player:setZPosition(self.landingPositionY - py)
    self.player:setPosition(self.landingPositionX, self.landingPositionY)
    self.player:setZVelocity(-self.velocityY)
    self.player:setVector(0, 0)

    Physics:update(self.player, self.player:getBumpPosition())
  end
end

function PlayerLedgeJumpState:update(dt)
  if self.ledgeJumpExtendsToNextRoom then
    if self.hasRoomChanged then
      if self.player:isOnGround() then
        self:endState()
      end
    else
      local x, y = self.player:getPosition()
      self.velocityY = self.velocityY + Constants.DEFAULT_GRAVITY
      y = y + self.velocityY
      self.player:setPosition(x, y)
      Physics:update(self.player, self.player:getBumpPosition())
    end
  else
    local x, y = vector.add(self.velocityX, self.velocityY, self.player:getPosition())
    self.player:setPosition(x, y)
    Physics:update(self.player, self.player:getBumpPosition())
    x, y = self.player:getPosition()
    x, y = vector.add(x, y, self.velocityX, self.velocityY)
    x, y = vector.sub(x, y, self.landingPositionX, self.landingPositionY)
    local dot = vector.dot(x, y, Direction4.getVector(self.direction4))
    if dot >= 0 then
      self.player:setZVelocity(0)
      self.player:setZPosition(0)
      self.player:setPosition(self.landingPositionX, self.landingPositionY)
      Physics:update(self.player, self.player:getBumpPosition())
      self:endState()
    end
  end
end

return PlayerLedgeJumpState
