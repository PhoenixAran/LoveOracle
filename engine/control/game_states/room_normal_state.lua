local Class = require 'lib.class'
local GameState = require 'engine.control.game_state'

local RoomNormalState = Class { __includes = GameState,
  init = function(self, room)
    GameState.init(self)
    self.room = room
  end
}

function RoomNormalState:getType()
  return 'room_normal_state'
end

function RoomNormalState:onBegin()
  self.room:load(self.gameControl:getEntities())
end

function RoomNormalState:onEnd()

end

function RoomNormalState:update(dt)
  self.gameControl:updateTileAnimations()
  self.gameControl:updateEntities(dt)
  self.gameControl:getCamera():update(dt)
  self.gameControl:getCamera():follow(self.gameControl:getPlayer():getPosition())
end

function RoomNormalState:draw()
  local camera = self.gameControl:getCamera()
  camera:attach()
  self.gameControl:drawTileEntities(camera.x - camera.w / 2, camera.y - camera.h / 2, camera.w, camera.h)
  self.gameControl:drawEntities()
  camera:detach()
end

return RoomNormalState