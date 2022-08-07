local Class = require 'lib.class'
local lume = require 'lib.lume'

---@class GameStateStack
---@field control GameControl
---@field states GameState[]
local GameStateStack = Class {
  init = function(self, control)
    self.control = control
    self.states = { }
  end
}

function GameStateStack:getType()
  return 'game_state_stack'
end

---@return GameState
function GameStateStack:getCurrentState()
  return lume.last(self.states)
end

---@param gameState GameState
function GameStateStack:pushState(gameState)
  gameState:begin(self.control)
  lume.push(self.states, gameState)
end

---remove current state from the stack
---@return GameState
function GameStateStack:popState()
  local state = self:getCurrentState()
  state:endState()
  assert(state)
  lume.remove(state)
  return state
end

return GameStateStack