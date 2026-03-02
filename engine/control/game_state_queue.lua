local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'

local GameState = require 'engine.control.game_state'

---@class GameStateQueue : GameState
---@field states GameState[]
---@field stateIndex integer
local GameStateQueue = Class { __includes = GameState,
  init = function(self, args)
    GameState.init(self)
    self.states = { }
    for _, state in ipairs(args.states) do
      lume.push(self.states, state)
    end
    self.stateIndex = 1
  end
}

function GameStateQueue:getType()
  return 'game_state_queue'
end 

function GameStateQueue:getCurrentState()
  if self.stateIndex > lume.count(self.states) then
    return nil
  end
  return self.states[self.stateIndex]
end

function GameStateQueue:nextState()
    self.stateIndex = self.stateIndex + 1
end

function GameStateQueue:count()
  return lume.count(self.states)
end

function GameStateQueue:onBegin()
  self.stateIndex = 0

  local currentState = self:getCurrentState()
  if currentState then
    currentState:begin(self.control) 
    if not currentState.active then
      self:nextState()
    end
  else
    self:endState()
  end
end

function GameStateQueue:update()
  local currentState = self:getCurrentState()
  if currentState then
    currentState:update()
    if not currentState.active then
      self:nextState()
    end
  else
    self:endState()
  end
end

function GameStateQueue:draw()
  local currentState = self:getCurrentState()
  if currentState then
    currentState:draw()
  end
end

return GameStateQueue