local Class = require 'lib.class'
local RoomState = require 'engine.control.room_state'
local Direction4 = require 'engine.enums.direction4'
local Tween = require 'lib.tween'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local Physics = require 'engine.physics'

local GRID_SIZE = 16
local RoomTransitionState = Class { __includes = RoomState,
  init = function(self, currentRoom, newRoom, transitionStyle, direction4)
    assert(transitionStyle == 'push', 'Only Push transitions are supported for now')
    RoomState.init(self)
    self.transitionStyle = transitionStyle
    self.currentRoom = currentRoom
    self.newRoom = newRoom
    self.transitionStyle = transitionStyle
    self.direction4 = direction4

    self.player = nil
    self.playerSubject = { x = 0, y = 0 }
    self.camera = nil
    self.cameraTarget = { }
    self.playerTween = nil
    self.cameraTween = nil
    self.playerTweenCompleted = false
    self.cameraTweenCompleted = false
  end
}

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

function RoomTransitionState:getType()
  return 'room_transition_state'
end

function RoomTransitionState:onBegin()
  local TWEEN_DURATION = 1

  self.roomControl.allowRoomTransition = false
  self.player = self.roomControl:getPlayer()
  self.camera = self.roomControl:getCamera()

  -- get target player position
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
  tx, ty = vector.mul(GRID_SIZE, tx, ty)

  -- setup player tween
  self.playerSubject.x, self.playerSubject.y = self.player:getPosition()
  if self.direction4 == Direction4.left or self.direction4 == Direction4.right then
    self.playerTween = Tween.new(TWEEN_DURATION, self.playerSubject, { x = tx, y = self.playerSubject.y }, 'linear')
  elseif self.direction4 == Direction4.up or self.direction4 == Direction4.down then
    self.playerTween = Tween.new(TWEEN_DURATION, self.playerSubject, { x = self.playerSubject.x, y = ty}, 'linear')
  end
  local x1, y1 = self.newRoom:getTopLeftPosition()
  x1 = x1 - 1
  y1 = y1 - 1
  local x2, y2 = self.newRoom:getBottomRightPosition()
  x1, y1 = vector.mul(GRID_SIZE, x1, y1)
  x2, y2 = vector.mul(GRID_SIZE, x2, y2)

  -- setup camera tween
  -- set camera target so it doesnt flicker position for one frame during transition
  self.camera.target_x = self.camera.x
  self.camera.target_y = self.camera.y
  self.cameraSubject = {
    x = self.camera.x,
    y = self.camera.y
  }
  self.cameraTarget = {
    x = self.camera.x,
    y = self.camera.y
  }
  if self.direction4 == Direction4.up then
    self.cameraTarget.y = y2 - self.camera.h / 2
  elseif self.direction4 == Direction4.down then
    self.cameraTarget.y = y1 + self.camera.h / 2
  elseif self.direction4 == Direction4.left then
    self.cameraTarget.x = x2 - self.camera.w / 2
  elseif self.direction4 == Direction4.right then
    self.cameraTarget.x = x1 + self.camera.w / 2
  end
  self.cameraTween = Tween.new(TWEEN_DURATION, self.cameraSubject, self.cameraTarget, 'linear')
  self.newRoom:load(self.roomControl:getEntities())
end

function RoomTransitionState:update(dt)
  self.playerTweenCompleted = self.playerTween:update(dt)
  self.cameraTweenCompleted = self.cameraTween:update(dt)
  self.player:setPosition(self.playerSubject.x, self.playerSubject.y)
  self.camera:update(dt)
  self.camera:follow(self.cameraSubject.x, self.cameraSubject.y)
  -- camera needs to have a call to update with new target values
  -- before setting bound to false
  self.camera.bound = false
  if self.playerTweenCompleted and self.cameraTweenCompleted then
    local x1, y1 = self.newRoom:getTopLeftPosition()
    x1 = x1 - 1
    y1 = y1 - 1
    local x2, y2 = self.newRoom:getBottomRightPosition()
    x1, y1 = vector.mul(GRID_SIZE, x1, y1)
    x2, y2 = vector.mul(GRID_SIZE, x2, y2)
    self.camera:setBounds(x1, y1, x2 - x1, y2 - y1)
    self.currentRoom:unload(self.roomControl:getEntities())
    self.roomControl:setCurrentRoom(self.newRoom)
    self.roomControl:popState()
    -- update player position or else they have one frame where they are considered in the last position between room transitons
    -- which can cause them to hit a room edge loading zone
    Physics.update(self.player)
  end
end

function RoomTransitionState:onEnd()
  resetUnusedTileDataAnimations(self.currentRoom, self.newRoom)
  self.roomControl.allowRoomTransition = true
end

function RoomTransitionState:draw()
  local camera = self.roomControl.camera
  local entities = self.roomControl.entities
  camera:attach()
  -- we want to force the tiles in the next room to draw the first frame of their animations
  local x = camera.x - camera.w / 2
  local y = camera.y - camera.h / 2
  local w = camera.w
  local h = camera.h
  entities:drawTileEntities(x, y, w, h)
  entities:drawEntities()
  camera:detach()
end

return RoomTransitionState