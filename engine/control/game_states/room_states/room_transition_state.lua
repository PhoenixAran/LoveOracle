local Class = require 'lib.class'
local GameState = require 'engine.control.game_state'
local Direction4 = require 'engine.enums.direction4'
local Tween = require 'lib.tween'
local lume = require 'lib.lume'
local vec2 = require 'lib.vector'
local Physics = require 'engine.physics'
local Consts = require 'constants'
local Camera = require 'engine.camera'

local ROOM_TRANSITION_PANNING_DURATION = 1
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
local RoomTransitionState = Class { __includes = GameState,
  init = function(self, currentRoom, newRoom, transitionStyle, direction4)
    GameState.init(self)
    self.transitionStyle = transitionStyle
    self.currentRoom = currentRoom
    self.newRoom = newRoom
    self.direction4 = direction4

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

function RoomTransitionState:onBegin()
  -- unset follow target for now
  Camera.setFollowTarget()
  self.control.allowRoomTransition = false
  self.player = self.control:getPlayer()

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
  local x,y = vec2.mul(Consts.GRID_SIZE, vec2.add(-1, -1, self.newRoom:getTopLeftPosition()))
  local w,h = vec2.mul(Consts.GRID_SIZE, self.newRoom:getWidth(), self.newRoom:getHeight())
  self.cameraTarget = {
    limitLeft = x,
    limitRight = x + w,
    limitTop = y,
    limitBottom = y + h
  }
  self.cameraTween = Tween.new(ROOM_TRANSITION_PANNING_DURATION, Camera, self.cameraTarget, ROOM_TRANSITION_TWEEN_STYLE)
  self.newRoom:load(self.control:getEntities())
end

function RoomTransitionState:update(dt)
  self.playerTweenCompleted = self.playerTween:update(dt)
  self.cameraTweenCompleted = self.cameraTween:update(dt)

  self.player:setPosition(self.playerSubject.x, self.playerSubject.y)
  Camera.update(dt)

  if self.playerTweenCompleted and self.cameraTweenCompleted then
    local x,y = vec2.mul(Consts.GRID_SIZE, vec2.add(-1, -1, self.newRoom:getTopLeftPosition()))
    local w,h = vec2.mul(Consts.GRID_SIZE, self.newRoom:getWidth(), self.newRoom:getHeight())
    Camera.setBounds(x,y,w,h)
    self.currentRoom:unload(self.control:getEntities())
    self.control:setCurrentRoom(self.newRoom)
    self.control:popState()
    -- update player position or else they have one frame where they are considered in the last position between room transitons
    -- which can cause them to hit a room edge loading zone
    Physics:update(self.player, self.player.x, self.player.y, self.player.w, self.player.h)
  end
end


function RoomTransitionState:onEnd()
  Camera.setFollowTarget(self.player)
  resetUnusedTileDataAnimations(self.currentRoom, self.newRoom)
  self.player:markRespawn()
  self.control.allowRoomTransition = true
end

function RoomTransitionState:draw()
  local entities = self.control:getEntities()
  local w,h = Camera.getSize()
  Camera.push()
    local x = Camera.x
    local y = Camera.y
    entities:drawTileEntities(x,y,w,h)
    entities:drawEntities(x,y,w,h)
  Camera.pop()

  -- HUD placeholder
  love.graphics.setColor(50 / 255, 50 / 255, 60 / 255)
  love.graphics.rectangle('fill', 0, 144 - 16, 160, 16)
  love.graphics.setColor(1,1,1)
end

return RoomTransitionState