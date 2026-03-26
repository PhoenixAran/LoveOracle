local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'

--- Used by GenericStateMachine to represent a single state. 
--- Meant for intenral use by GenericStateMachine
--- @class GenericState
--- @field init function we get this from the class module
--- @field id any the id of this state
--- @field context any? context of this state that will be passed into the begin/update/end functions as the first parameter. Usually the Entity
--- @field beginFunc function?
--- @field updateFunc function?
--- @field endFunc function?
--- @field stateMachine GenericStateMachine the state machine that this state belongs to
--- @field active boolean whether this state is currently active
local GenericState = Class {
  init = function(self, genericStateMachine)
    self.stateMachine = genericStateMachine
    self.id = nil
    self.beginFunc = nil
    self.updateFunc = nil
    self.endFunc = nil
    self.active = false
  end
}

function GenericState:getType()
  return 'generic_state'
end

function GenericState:begin()
  if self.beginFunc then
    self.beginFunc(self.stateMachine:getContext())
  end
  self.active = true
end

function GenericState:update()
  if self.updateFunc then
    self.updateFunc(self.stateMachine:getContext())
  end
end

function GenericState:endState()
  if self.endFunc then
    self.endFunc(self.stateMachine:getContext())
  end
  self.active = false
end


---@class TimedState : GenericState
---@field tick integer
---@field rangeMin integer
---@field rangeMax integer
---@field nextStateId any
---@field timedActions table<integer, function> a table mapping ticks to functions that will be called at that tick. The tick will be checked against the rangeMin and rangeMax to determine if the function should be called
---@field timedActionsList table<{tick: integer, func: function}> a list of the timed actions in order of their ticks. This is used to iterate through the timed actions in order without having to sort the keys of the timedActions table
---@field activeDuration integer
local TimedState = Class { __includes = GenericState,
  init = function(self, genericStateMachine)
    GenericState.init(self, genericStateMachine)
    self.tick = 0
    self.rangeMin = -1
    self.rangeMax = -1
    self.nextStateId = nil
    self.timedActions = { }
    self.timedActionsList = { }
    self.activeDuration = 0
  end
}

function TimedState:getType()
  return 'timed_state'
end

---@param tick integer
---@param func function
---@return TimedState
function TimedState:addEvent(tick, func)
  self.timedActions[tick] = func
  lume.push(self.timedActionsList, { tick = tick, func = func })
  return self
end


---@param func function
---@return TimedState
function TimedState:onBegin(func)
  self.beginFunc = func
  return self
end

---@param func function
---@return TimedState
function TimedState:onEnd(func)
  self.endFunc = func
  return self
end

function TimedState:onUpdate(func)
  self.updateFunc = func
  return self
end

function TimedState:appendEvent(delay, func)
  local tick = delay
  if lume.count(self.timedActionsList) > 0 then
    tick = tick + self.timedActionsList[lume.count(self.timedActionsList)].tick
  end
  return self:addEvent(tick, func)
end

function TimedState:setDuration(minDuration, maxDuration)
  self.rangeMin = minDuration
  self.rangeMax = maxDuration
  return self
end

---@overload fun(self: TimedState): TimedState
function TimedState:begin()
  GenericState.begin(self)
  self.tick = 0
  self.activeDuration = lume.round(lume.random(self.rangeMin, self.rangeMax))
end

---@overload fun(self: TimedState): any
function TimedState:update()
  GenericState.update(self)
  if self.active then
    self.tick = self.tick + 1
    for _, timedAction in ipairs(self.timedActionsList) do
      if timedAction.tick == self.tick then
        timedAction.func(self.stateMachine:getContext())
      end
    end
    if self.activeDuration >= 0 and self.tick >= self.activeDuration then
      self.stateMachine:nextState()
    end
  end
end


--- stateType must be a map like { Key = integerValue }.
--- The integer values are used as state IDs and for nextState() ordering.
--- Values should be unique and preferably sequential (1..n).
--- Order is not guaranteed unless stateIds is sorted.
---@class GenericStateMachine
---@field context any the context that will be passed into the begin/update/end functions of each state as the first parameter. Example would be an Entity
---@field states table<any, GenericState> a table mapping state ids to GenericState objects
---@field stateIds any[] a list of the state ids
---@field currentState GenericState the current state
local GenericStateMachine = Class {
  ---@param self GenericStateMachine
  ---@param context any?
  ---@param stateType table<any, any> enum state map 
  init = function(self, context, stateType)
    self.context = context
    self.states = { }
    self.stateIds = { }
    for k, v in pairs(stateType) do
      lume.push(self.stateIds, v)
    end
    lume.sort(self.stateIds)
  end
}

function GenericStateMachine:getType()
  return 'generic_state_machine'
end

function GenericStateMachine:getContext()
  return self.context
end

--- add a new state using the given Id
---@param stateId any
---@return TimedState
function GenericStateMachine:addState(stateId)
  local timedState = TimedState(self)
  timedState.id = stateId
  self.states[stateId] = timedState
  return timedState
end


--- begin the state machine on the state with the given Id
--- this will not end the previous state if one was active
---@param stateId any
function GenericStateMachine:initializeOnState(stateId)
  self.currentState = self.states[stateId]
  if self.currentState then
    self.currentState:begin()
  end
end


--- begin or transition to the state with the given id
---@param stateId any
function GenericStateMachine:beginState(stateId)
  if self.currentState then
    self.currentState:endState()
  end
  self.currentState = self.states[stateId]
  if self.currentState then
    self.currentState:begin()
  end
end

--- ends the currently active state
function GenericStateMachine:endCurrentState()
  if self.currentState then
    self.currentState:endState()
    self.currentState = nil
  end
end

--- transition to the next state as defined by the order of the state ID values
function GenericStateMachine:nextState()
  local index = lume.find(self.stateIds, self.currentState.id)
  index = (index % lume.count(self.stateIds)) + 1
  self:beginState(self.stateIds[index])
end

function GenericStateMachine:update()
  if self.currentState then
    self.currentState:update()
  end
end

return GenericStateMachine