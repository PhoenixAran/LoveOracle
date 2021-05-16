local Class = require 'lib.class'
local GameState = require 'engine.control.game_state'

local RoomNormalState = Class { __includes = GameState,
  init = function(self, room)
    GameState.init(self)
    self.room = room
    self.player = nil
    self.camera = nil
  end
}

function RoomNormalState:getType()
  return 'room_normal_state'
end

function RoomNormalState:onBegin()
  self.player = self.gameControl:getPlayer()
  self.camera = self.gameControl:getCamera()
end

function RoomNormalState:onEnd()
  self.room = nil
  self.player = nil
  self.camera = nil
end

function RoomNormalState:update(dt)
  self.gameControl:updateTileAnimations()
  self.gameControl:updateEntities(dt)
  self.camera:update(dt)
  self.camera:follow(self.player:getPosition())
end

function RoomNormalState:draw()
  local camera = self.gameControl:getCamera()
  camera:attach()
  self.gameControl:drawTileEntities(camera.x - camera.w / 2, camera.y - camera.h / 2, camera.w, camera.h)
  self.gameControl:drawEntities()
  camera:detach()
end

return RoomNormalState