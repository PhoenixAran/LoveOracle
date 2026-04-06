local Class = require 'lib.class'
local lume = require 'lib.lume'
local PlayerState = require 'engine.player.player_state'

---@class PlayerBusyState : PlayerState
---@field timer integer
---@field duration integer
---@field timedActions table<integer, function>
---@field animation string
---@field endAction function
local PlayerBusyState = Class { __includes = PlayerState,
  init = function(self, duration, animation)
    if duration == nil then duration = 0 end
    PlayerState.init(self)
    self.timer = 0
    self.duration = duration
    self.timedActions = { }
    self.animation = animation
    self.endAction = nil
  end
}

function PlayerBusyState:getType()
  return 'player_busy_state'
end

function PlayerBusyState:getAnimation()
  return self.animation
end

---@param time integer
---@param func function
function PlayerBusyState:addTimedAction(time, func)
  -- add + 1 for lua arrays
  self.timedActions[time + 1] = func
end

---@param func function
function PlayerBusyState:setEndAction(func)
  self.endAction = func
end

-- override playerstate methods
---@param previousState PlayerState?
function PlayerBusyState:onBegin(previousState)
  self.stateParameters.canJump = false
  self.stateParameters.canWarp = false
  self.stateParameters.canLedgeJump = false
  self.stateParameters.canControlOnGround = false
  self.stateParameters.canControlInAir = false
  self.stateParameters.canPush = false
  self.stateParameters.canUseWeapons = false
  self.stateParameters.canRoomTransition = false
  self.stateParameters.canStrafe = false

  self.timer = 0

  if self.timedActions[1] then
    self.timedActions[1](self)
  end
end

---@param newState PlayerState?
function PlayerBusyState:onEnd(newState)
  self.timer = 0
  self.duration = 0
  lume.clear(self.timedActions)
  if self.endAction ~= nil then
    self.endAction(self)
  end
end

function PlayerBusyState:update()
  PlayerState.update(self)
  self.timer = self.timer + 1
  if self.timedActions[self.timer + 1] then
    self.timedActions[self.timer + 1](self)
  end
  if self.duration <= self.timer then
    self:endState()
  end
end

return PlayerBusyState