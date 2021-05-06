local Class = require 'lib.class'
local lume = require 'lib.lume'

local GameStateStack = Class {
  init = function(self, gameControl)
    self.gameCntrol = gameControl
    self.states = { }
  end
}

function GameStateStack:getCurrentState()
  return lume.last(self.states)
end

function GameStateStack:pushState(gameState)
  gameState:onBegin()
  lume.push(self.states, gameState)
end

function GameStateStack:popState()
  local state = self:getCurrentState()
  assert(state)
  lume.remove(state)
  return state
end

function GameStateStack:getType()
  return 'game_state_stack'
end

return GameStateStack