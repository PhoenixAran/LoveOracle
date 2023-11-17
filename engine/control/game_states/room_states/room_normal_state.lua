local Class = require 'lib.class'
local GameState = require 'engine.control.game_state'
local GRID_SIZE = require('constants').GRID_SIZE

---@class RoomNormalState : GameState
local RoomNormalState = Class { __includes = GameState,
  init = function(self)
    GameState.init(self)
  end
}

function RoomNormalState:getType()
  return 'room_normal_state'
end

function RoomNormalState:update(dt)
  local camera = self.control.camera
  local entities = self.control.entities
  local player = self.control.player
  local room = self.control.currentRoom
  entities:update(dt)
  camera:follow(player:getPosition())
  camera:update(dt)
  room:updateAnimatedTiles(dt)
end

function RoomNormalState:draw()
  local camera = self.control.camera
  local entities = self.control.entities
  camera:attach()
  local x = camera.x - camera.w / 2
  local y = camera.y - camera.h / 2
  local w = camera.w
  local h = camera.h
  entities:drawTileEntities(x, y, w, h)
  entities:drawEntities()
  camera:detach()
end


return RoomNormalState