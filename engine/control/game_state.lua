local Class = require 'lib.class'

local GameState = Class {
  init = function(self, gameControl)
    self.active = true
    self.visible = true
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
  if not self.isActive then
    self.active = true
    self.gameControl = gameControl
    self:onBegin()
  end
end

function GameState:endState()
  if self.isActive then
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