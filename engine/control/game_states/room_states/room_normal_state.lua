local Class = require 'lib.class'
local RoomState = require 'engine.control.room_state'

---@class RoomNormalState : RoomState
local RoomNormalState = Class { __includes = RoomState,
  init = function(self)
    RoomState.init(self)
  end
}

function RoomNormalState:getType()
  return 'room_normal_state'
end

function RoomNormalState:update(dt)
  local camera = self.roomControl.camera
  local entities = self.roomControl.entities
  local player = self.roomControl.player
  local room = self.roomControl.currentRoom
  entities:update(dt)
  camera:follow(player:getPosition())
  camera:update(dt)
  room:updateAnimatedTiles(dt)
end

function RoomNormalState:draw()
  local camera = self.roomControl.camera
  local entities = self.roomControl.entities
  camera:attach()
  local x = camera.x - camera.w / 2
  local y = camera.y - camera.h / 2
  local w = camera.w
  local h = camera.h
  entities:drawTileEntities(x, y, w, h)
  entities:drawEntities()
  camera:detach()
  camera:draw()
end


return RoomNormalState