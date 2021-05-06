local Class = require 'lib.class'
local GameState = require 'engine.control.game_state'

local RoomNormalState = Class { __includes = GameState,
  init = function(self, gameControl)
    GameState.init(self, gameControl)
  end
}

function RoomNormalState:getType()
  return 'room_normal_state'
end

function RoomNormalState:onBegin()

end

function RoomNormalState:onEnd()

end

function RoomNormalState:update(dt)
  self.gameControl:updateTileAnimations()
  self.gameControl:updateEntities(dt)
end

function RoomNormalState:draw()
  self.gameControl:drawEntitites()
end



return RoomNormalState