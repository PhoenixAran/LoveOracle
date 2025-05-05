local Class = require 'lib.class'
local GameState = require 'engine.control.game_state'
local Direction4 = require 'engine.enums.direction4'
local Tween = require 'lib.tween'
local lume = require 'lib.lume'
local vec2 = require 'engine.math.vector'
local Physics = require 'engine.physics'
local Consts = require 'constants'
local Camera = require 'engine.camera'
local AssetManager = require 'engine.asset_manager'

local ROOM_TRANSITION_PANNING_DURATION = .80
local ROOM_TRANSITION_TWEEN_STYLE = 'inOutCubic'

---@class RoomTransitionState : GameState
---@field transitionStyle string
---@field currentRoom Room
---@field newRoom Room
---@field player Player
---@field playerSubject table
---@field cameraTarget table
---@field playerTween any
---@field cameraTween any
---@field playerTweenCompleted boolean
---@field cameraTweenCompleted boolean
---@field direction4 integer
---@field previousPositionSmoothingEnabledValue boolean
local RoomTransitionState = Class { __includes = GameState,
  init = function(self, currentRoom, newRoom, transitionStyle, direction4)
    GameState.init(self)
    self.transitionStyle = transitionStyle
    self.currentRoom = currentRoom
    self.newRoom = newRoom
    self.direction4 = direction4
    self.previousPositionSmoothingEnabledValue = Camera.positionSmoothingEnabled

    self.player = nil
    self.playerSubject = { }
    self.playerTween = nil
    self.cameraTween = nil
    self.playerTweenCompleted = false
    self.cameraTweenCompleted = false
  end
}

function RoomTransitionState.getType()
  return 'room_transition_state'
end

---@param oldRoom Room
---@param newRoom Room
local function resetUnusedTileDataAnimations(oldRoom, newRoom)
  -- array of tile data with tiles that were animated in the last room,
  -- but are not used in the new room
  local tileDatas = { }
  for k, tileData in pairs(oldRoom.animatedTiles) do
    if not newRoom.animatedTiles[k] then
      lume.push(tileDatas, tileData)
    end
  end
  lume.each(tileDatas, function(tileData)
    tileData.sprite:resetSpriteAnimation()
  end)
end

---@param direction4 integer
---@return integer targetCamX
---@return integer targetCamY
local function calculatePushTransitionTargetCameraPosition(direction4)
  local camX, camY = Camera.x, Camera.y
  local camW, camH = Camera.getSize()
  if direction4 == Direction4.up then
    return camX, camY - camH
  elseif direction4 == Direction4.down then
    return camX, camY + camH
  elseif direction4 == Direction4.left then
    return camX - camW, camY
  elseif direction4 == Direction4.right then
    return camX + camW, camY
  end
  error('Direction required to calculate push transition target camera position')
end

function RoomTransitionState:onBegin()
  -- unbound camera so it can move freely during the push transition
  Camera.setFollowTarget()
  Camera.setLimits(-10000000, 10000000, -10000000, 10000000)
  
  -- disable positional smoothing if it is enabled
  self.previousPositionSmoothingEnabledValue = Camera.positionSmoothingEnabled
  Camera.positionSmoothingEnabled = false

  self.control.allowRoomTransition = false
  self.player = self.control:getPlayer()
  -- call player onLeaveRoom
  self.player:onLeaveRoom()

  -- setup player tween
  local tx, ty = 0, 0
  if self.direction4 == Direction4.up then
    tx, ty = self.newRoom:getBottomRightPosition()
    ty = ty + 0.6
  elseif self.direction4 == Direction4.down then
    tx, ty = self.newRoom:getTopLeftPosition()
    ty = ty + 0.6
  elseif self.direction4 == Direction4.left then
    tx, ty = self.newRoom:getBottomRightPosition()
    tx = tx + 0.6
  elseif self.direction4 == Direction4.right then
    tx, ty = self.newRoom:getTopLeftPosition()
    tx = tx + 0.4
  end
  tx = tx - 1
  ty = ty - 1
  tx, ty = vec2.mul(Consts.GRID_SIZE, tx, ty)
  self.playerSubject = { }
  self.playerSubject.x, self.playerSubject.y = self.player:getPosition()
  if self.direction4 == Direction4.left or self.direction4 == Direction4.right then
    self.playerTween = Tween.new(ROOM_TRANSITION_PANNING_DURATION, self.playerSubject, { x = tx, y = self.playerSubject.y }, ROOM_TRANSITION_TWEEN_STYLE)
  elseif self.direction4 == Direction4.up or self.direction4 == Direction4.down then
    self.playerTween = Tween.new(ROOM_TRANSITION_PANNING_DURATION, self.playerSubject, { x = self.playerSubject.x, y = ty}, ROOM_TRANSITION_TWEEN_STYLE)
  end

  -- setup camera tween
  local targetCamX, targetCamY = calculatePushTransitionTargetCameraPosition(self.direction4)
  self.cameraTween = Tween.new(ROOM_TRANSITION_PANNING_DURATION, Camera, { x = targetCamX, y = targetCamY}, ROOM_TRANSITION_TWEEN_STYLE)
  self.newRoom:load(self.control:getEntities())
end

function RoomTransitionState:update()
  self.playerTweenCompleted = self.playerTween:update(love.time.dt)
  self.cameraTweenCompleted = self.cameraTween:update(love.time.dt)

  self.player:setPosition(self.playerSubject.x, self.playerSubject.y)
  Camera.update()

  if self.playerTweenCompleted and self.cameraTweenCompleted then
    self.control:popState()
  end
end


function RoomTransitionState:onEnd()
  -- call player:onEnterRoom
  self.player:onEnterRoom()

  self.currentRoom:unload(self.control:getEntities())

  resetUnusedTileDataAnimations(self.currentRoom, self.newRoom)

  -- reclamp camera to the room
  local x1, y1 = self.newRoom:getTopLeftPosition()
  local x2, y2 = self.newRoom:getBottomRightPosition()
  x1 = x1 - 1
  y1 = y1 - 1
  x1, y1 = vec2.mul(Consts.GRID_SIZE, x1, y1)
  x2, y2 = vec2.mul(Consts.GRID_SIZE, x2, y2)
  Camera.setLimits(x1, x2, y1, y2)
  -- set camera to follow player again
  Camera.setFollowTarget(self.player)

  -- re enable position smoothing if it was enabled before
  Camera.positionSmoothingEnabled = self.previousPositionSmoothingEnabledValue
  self.player:markRespawn()
  -- update player position or else they have one frame where they are considered in the last position between room transitions
  -- which can cause them to hit a room edge loading zone
  Physics:update(self.player, self.player.x, self.player.y, self.player.w, self.player.h)

  -- game state
  self.control:setCurrentRoom(self.newRoom)
  self.control.allowRoomTransition = true
end

function RoomTransitionState:draw()
  local entities = self.control:getEntities()
  local entityDebugDrawFlags = self.control.control.entityDebugDrawFlags
  local w,h = Camera.getSize()
  Camera.push()
    local x = Camera.positionSmoothingEnabled and Camera.smoothedX or Camera.x
    local y = Camera.positionSmoothingEnabled and Camera.smoothedY or Camera.y
    entities:drawTileEntities(x,y,w,h)
    entities:drawEntities(x,y,w,h)

    if self.control.control.entityDebugDrawFlags ~= 0 then
      entities:debugDrawEntities(x,y,w,h, entityDebugDrawFlags)
    end
  Camera.pop()

  -- HUD placeholder
  love.graphics.setColor(50 / 255, 50 / 255, 60 / 255)
  love.graphics.rectangle('fill', 0, 144 - 16, 160, 16)
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(AssetManager.getFont('game_font'))
  love.graphics.print('HUD Placeholder', 8, 130)
end

return RoomTransitionState