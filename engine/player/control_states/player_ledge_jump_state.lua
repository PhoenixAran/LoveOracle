local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local vector = require 'engine.math.vector'
local Direction4 = require 'engine.enums.direction4'
local bit = require 'bit'
local Singletons = require 'engine.singletons'
local Constants = require 'constants'
local Physics = require 'engine.physics'
local tick = require 'lib.tick'

local function queryTileFilter(item)
  if item.isTile and item:isTile() and item:isTopTile() then
    return true
  end
  return false
end

---@class PlayerLedgeJumpState : PlayerState
---@field speed number
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
    self.stateParameters.canControlOnGround = false
    self.stateParameters.canControlInAir = false
    self.stateParameters.canUseWeapons = false
    self.stateParameters.canReleaseSword = false
    self.stateParameters.canUseWeapons = false

    self._playerBumpBox = { }
  end
}

function PlayerLedgeJumpState:getType()
  return 'player_ledge_jump_state'
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

function PlayerLedgeJumpState:getLandingPosition(posX, posY)
  local moveVectorX, moveVectorY = Direction4.getVector(self.direction4)
  local landingPositionX, landingPositionY = vector.add(posX, posY, vector.mul(4, moveVectorX, moveVectorY))
  while not self:canLandAtPosition(landingPositionX, landingPositionY) do
    landingPositionX, landingPositionY = vector.add(landingPositionX, landingPositionY, moveVectorX, moveVectorY)
  end
  landingPositionX, landingPositionY = vector.add(landingPositionX, landingPositionY, moveVectorX, moveVectorY)
  return landingPositionX, landingPositionY
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

  if self.player:getWeaponState() == nil then
    self.player.sprite:play('jump')
  else
    self.player.sprite:play(self.player:getStateParameters().animations.default)
  end

  local px, py = self.player:getPosition()
  self.landingPositionX, self.landingPositionY = self:getLandingPosition(px, py)

  local roomControl = Singletons.gameControl:getRoomControl()
  if not roomControl:inRoomBounds(px, py) then
    -- TODO ledge jump into next room stuff
    self.ledgeJumpExtendsToNextRoom = true
    self.hasRoomChanged = false
  
  else
    -- determine jump speed based on the distance needed to move
    -- smaller ledge distances have slower jump speeds
    local direction4VectorX, direction4VectorY = Direction4.getVector(self.direction4)
    local tx, ty = vector.sub(self.landingPositionX, self.landingPositionY, px, py)
    local distance = vector.dot(tx, ty, direction4VectorX, direction4VectorY)

    local jumpSpeed = 1.5
    if distance >= 28 then
      jumpSpeed = 2.0
    elseif distance >= 20 then
      jumpSpeed = 1.75
    end
    local jumpTime = (2 / jumpSpeed) / (Constants.DEFAULT_GRAVITY * tick.rate)
    local speed = distance / jumpTime
    if speed >= 7 then
      -- TODO make faster
      speed = math.sqrt((distance / 2) * Constants.DEFAULT_GRAVITY * tick.rate) / tick.rate
    end

    self.speed = speed
    self.ledgeJumpExtendsToNextRoom = false
    self.player:setZVelocity(jumpSpeed)
  end
end

function PlayerLedgeJumpState:onEnd(newState)
  -- reenable collisions by giving back bump filters
  self.player.moveFilter = self._playerMoveFilter
  self.player.roomEdgeCollisionBoxMoveFilter = self._playerRoomEdgeCollisionBoxMoveFilter

  if self.ledgeJumpExtendsToNextRoom then
    self.player:markRespawn()
  end
end

function PlayerLedgeJumpState:onEnterRoom()
  -- TODO
end

function PlayerLedgeJumpState:update()
  if self.ledgeJumpExtendsToNextRoom then
    -- TODO
  else
    local vecX, vecY = Direction4.getVector(self.direction4)
    local px, py = self.player:getBumpPosition()
    local velX, velY = vector.mul(self.speed * love.time.dt, vecX, vecY)
    px, py = vector.add(px, py, velX, velY)
    self.player:setPositionWithBumpCoords(px, py)
    Physics:update(self.player, px, py)

    local x, y = self.player:getPosition()
    x, y = vector.sub(x, y, self.landingPositionX, self.landingPositionY)
    local dot = vector.dot(x, y, vecX, vecY)
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
