local Class = require 'lib.class'

local GameState = Class {
  init = function(self)
    self.active = false
    self.visible = false
    self.gameControl = nil
  end
}

function GameState:getType()
  return 'game_state'
end

function GameState:onBegin()
end

function GameState:onEnd()

end

function GameState:begin(gameControl)
  if not self.active then
    self.active = true
    self.gameControl = gameControl
    self:onBegin()
  end
end

function GameState:endState()
  if self.active  then
    self.active = false
    self.gameControl = nil
    self:onEnd()
  end
end

function GameState:update(dt)

end

function GameState:draw()

end

return GameState