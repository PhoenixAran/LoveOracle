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
    self.timer = 1
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
  self.timedActions[time] = func
end

---@param func function
function PlayerBusyState:setEndAction(func)
  self.endAction = func
end

-- override playerstate methods
---@param previousState PlayerState?
function PlayerBusyState:onBegin(previousState)
    self.canJump = false
    self.canWarp = false
    self.canLedgeJump = false
    self.canControlOnGround = false
    self.canControlInAir = false
    self.canPush = false
    self.canUseWeapons = false
    self.canRoomTransition = false
    self.canStrafe = false

    self.timer = 1
    --[[
    not sure if i should invoke the first timed action here
    or just let it naturally happen in the update method
    if self.timedActions[1] then
      self.timedActions[1](self)
    end
    ]]--
end

---@param newState PlayerState?
function PlayerBusyState:onEnd(newState)
  self.timer = 1
  self.duration = 0
  lume.clear(self.timedActions)
  if self.endAction ~= nil then
    self.endAction(self)
  end
end

function PlayerBusyState:update()
  PlayerState.update(self)
  if self.timedActions[self.timer] then
    self.timedActions[self.timer](self)
  end
  self.timer = self.timer + 1
  if self.duration <= self.timer then
    self:endState()
  end
end

return PlayerBusyState