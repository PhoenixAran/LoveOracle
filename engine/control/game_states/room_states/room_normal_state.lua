local Class = require 'lib.class'
local GameState = require 'engine.control.game_state'
local GRID_SIZE = require('constants').GRID_SIZE
local Camera = require 'engine.camera'
local DisplayHandler = require 'engine.display_handler'
local AssetManager = require 'engine.asset_manager'

---@class RoomNormalState : GameState
local RoomNormalState = Class { __includes = GameState,
  init = function(self)
    GameState.init(self)
  end
}

function RoomNormalState:getType()
  return 'room_normal_state'
end

function RoomNormalState:update()
  local entities = self.control.entities
  local player = self.control.player
  local room = self.control.currentRoom
  assert(room)
  entities:update()
  Camera.update()
  room:updateAnimatedTiles()
end

function RoomNormalState:draw()
  local entities = self.control.entities
  Camera.push()
    local gameW, gameH = Camera.getSize()
    local cullX = Camera.positionSmoothingEnabled and Camera.smoothedX or Camera.x
    local cullY = Camera.positionSmoothingEnabled and Camera.smoothedY or Camera.y
    local cullW = gameW
    local cullH = gameH
    entities:drawTileEntities(cullX, cullY, cullW, cullH)
    entities:drawEntities(cullX, cullY, cullW, cullH)
  Camera.pop()

  -- HUD placeholder
  love.graphics.setColor(50 / 255, 50 / 255, 60 / 255)
  love.graphics.rectangle('fill', 0, 144 - 16, 160, 16)
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(AssetManager.getFont('game_font'))
  love.graphics.print('HUD Placeholder', 8, 130)
end


return RoomNormalState