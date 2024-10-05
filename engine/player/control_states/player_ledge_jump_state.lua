local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local vector = require 'engine.math.vector'
local Direction4 = require 'engine.enums.direction4'
local bit = require 'bit'
local Singletons = require 'engine.singletons'
local Constants = require 'constants'
local Physics = require 'engine.physics'

local function queryTileFilter(item)
  if item.isTile and item:isTile() and item:isTopTile() then
    return true
  end
  return false
end

local function dummyMoveFilter(item, other)
  return nil
end

---@class PlayerLedgeJumpState : PlayerState
---@field direction4 Direction4
---@field ledgeJumpExtendsToNextRoom boolean
---@field hasRoomChanged boolean
---@field landingPositionX number
---@field landingPositionY number
---@field originalSpeedScale number
---@field jumpSpeed number
---@field fakeZVelocity number
---@field spriteOffsetY number
---@field originalSpriteOffsetY number
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

    self.speedScale = 1

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
  --print('==============')
  --print('Starting coords:  ' .. posX .. ' ' .. posY)
  local moveVectorX, moveVectorY = Direction4.getVector(self.direction4)
  local landingPositionX, landingPositionY = vector.add(posX, posY, vector.mul(4, moveVectorX, moveVectorY))
  while not self:canLandAtPosition(landingPositionX, landingPositionY) do
    landingPositionX, landingPositionY = vector.add(landingPositionX, landingPositionY, moveVectorX, moveVectorY)
    --print('iterating on ' .. landingPositionX .. ' ' .. landingPositionY)
  end
  --print('Finalizing on ' .. landingPositionX .. ' ' .. landingPositionY)
  landingPositionX, landingPositionY = vector.add(landingPositionX, landingPositionY, moveVectorX, moveVectorY)
  return landingPositionX, landingPositionY
end


function PlayerLedgeJumpState:onBegin(previousState)
  -- cancel pushing since ledges are usually inline with walls
  self.player:stopPushing()
  self.originalSpriteOffsetY = self.player.sprite:getOffsetY()
  self.originalSpeedScale = self.player.movement:getSpeedScale()
  self.spriteOffsetY = self.originalSpriteOffsetY
  --temporarily disable solid collisions by replacing moveFilter
  self._playerMoveFilter = self.player.moveFilter
  self.player.moveFilter = dummyMoveFilter

  -- animation stuff
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
  if not roomControl:inRoomBounds(self.landingPositionX, self.landingPositionY) then
    -- TODO ledge jump into next room stuff
    self.ledgeJumpExtendsToNextRoom = true
    self.hasRoomChanged = false
  else
    --Determine the jump speed based on the distance needed to move
    --Smaller ledge distances have slower jump speeds
    local direction4VectorX, direction4VectorY = Direction4.getVector(self.direction4)
    local diffX, diffY = vector.sub(self.landingPositionX, self.landingPositionY, px, py)
    local distance = vector.dot(diffX, diffY, direction4VectorX, direction4VectorY)
    
    -- when we jump, it will use the speed from player_environment_jump_state
    local jumpState = self.player:getStateFromCollection('player_jump_environment_state')

    -- TODO maybe max out the y offset of the sprite so it doesnt look stupid when ledge jumping long distances
    local jumpSpeed = 1.5
    if distance >= 71 then
      jumpSpeed = 5
    elseif distance >= 43 then
      jumpSpeed = 1.75
    elseif distance >= 27 then
      jumpSpeed = 2
    end

    -- determine time it takes to drop back to ground
    local timeDown = 2 * (jumpSpeed / Constants.DEFAULT_GRAVITY)
    local speedScale = distance / (jumpState.motionSettings.speed * timeDown)
  
    self.player:setZVelocity(jumpSpeed)
    self.player:setSpeedScale(speedScale)
  end
end

function PlayerLedgeJumpState:onEnd(newState)
  -- reenable collisions by giving back bump filter
  self.player.moveFilter = self._playerMoveFilter
  -- give back it's original speed scale
  self.player:setSpeedScale(self.originalSpeedScale)
  if self.ledgeJumpExtendsToNextRoom then
    self.player:markRespawn()
  end
  self.player.sprite:setMaxOffsetY(nil)
end

function PlayerLedgeJumpState:onEnterRoom()
  print 'player_ledge_jump_state::onEnterRoom'
  if self.ledgeJumpExtendsToNextRoom then
    self.hasRoomChanged = true
    local px, py = self.player:getPosition()
    self.landingPositionX, self.landingPositionY = self:getLandingPosition(px, py)
    -- move the player to the landing spot, and raise it's z position
    -- so that it falls onto the landing spot
    self.player:setZPosition(self.landingPositionY - py)
    self.player:setPosition(self.landingPositionX, self.landingPositionY)
    Physics:update(self.player, self.player:getBumpPosition())
  end
end

function PlayerLedgeJumpState:update()
  if self.ledgeJumpExtendsToNextRoom then
    if self.hasRoomChanged then
      -- stop slippery movement from moving player off original target set in onEnterRoom if 
      -- landing position is in next room
      self.player.movement.motionX = 0
      self.player.movement.motionY = 0
      if self.player:isOnGround() then
        self:endState()
      end
    else 
      self.player:setVector(Direction4.getVector(self.direction4))
    end
  else
    self.player:setVector(Direction4.getVector(self.direction4))
    
    local x, y = self.player:getPosition()
    x, y = vector.sub(x, y, self.landingPositionX, self.landingPositionY)
    local dot = vector.dot(x, y, Direction4.getVector(self.direction4))
    if dot >= 0 then
      -- set to it's exact landing position
      self.player:setPosition(self.landingPositionX, self.landingPositionY)
      Physics:update(self.player, self.player:getBumpPosition())
      self:endState()
    end
  end
end

return PlayerLedgeJumpState