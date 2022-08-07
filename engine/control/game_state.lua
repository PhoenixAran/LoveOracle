local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'

---@class GameState : SignalObject
---@field active boolean
---@field visible boolean
---@field control GameControl|RoomControl
---@field init function
local GameState = Class { _includes = SignalObject,
  init = function(self)
    SignalObject.init(self)
    self.active = false
    self.visible = false
    self.control = nil
  end
}

function GameState:getType()
  return 'game_state'
end


function GameState:onBegin()
end

function GameState:onEnd()

end

--- called when gamestate is being set as the current state
---@param gameControl GameControl
function GameState:begin(gameControl)
  if not self.active then
    self.active = true
    self.control = gameControl
    self:onBegin()
  end
end

function GameState:endState()
  if self.active then
    self:onEnd()
    self.active = false
    self.control = nil
  end
end

function GameState:update(dt)
end

function GameState:draw()

end

return GameState