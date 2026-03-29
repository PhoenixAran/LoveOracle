local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local PlayerState = require 'engine.player.player_state'
local GenericStateMachine = require 'engine.utils.generic_state_machine'

local ShieldState = {
  notBlocking = 1,
  blocking = 2
}


---@class PlayerShieldState : PlayerState
---@field shieldState integer
---@field shield ItemShield
---@field subStateMachine GenericStateMachine
local PlayerShieldState = Class { __includes = PlayerState,
  init = function(self, args)
    PlayerState.init(self, args)
    self.shieldState = ShieldState.notBlocking

    self.subStateMachine = GenericStateMachine(self, ShieldState)
    self.subStateMachine:addState(ShieldState.notBlocking)
                        :onBegin(self.onBeginNotBlockingState)
                        :onUpdate(self.onUpdateNotBlockingState)
    self.subStateMachine:addState(ShieldState.blocking)
                        :onBegin(self.onBeginBlockingState)
                        :onUpdate(self.onUpdateBlockingState)
  end
}

function PlayerShieldState:getType()
  return 'player_shield_state'
end

function PlayerShieldState:onBeginNotBlockingState()
  self.shieldState = ShieldState.notBlocking
  self.stateParameters.canPush = true
  
  -- set the player's default animation
  if self.shield:getLevel() == 1 then
    self.stateParameters.animations.default = 'idle_shield'
    self.stateParameters.animations.move = 'walk_shield'
  else
    self.stateParameters.animations.default = 'idle_shield'
    self.stateParameters.animations.move = 'walk_shield_large'
  end

  self.shield:stopBlocking()
end

function PlayerShieldState:onUpdateNotBlockingState()
  -- set the player's default animation
  -- if self.shield:getLevel() == 1 then
  --   self.stateParameters.animations.default = 'idle_shield'
  --   self.stateParameters.animations.move = 'walk_shield'
  -- else
  --   self.stateParameters.animations.default = 'idle_shield_large'
  --   self.stateParameters.animations.move = 'walk_shield_large'
  -- end
  self.stateParameters.animations.default = 'idle_shield'
  self.stateParameters.animations.move = 'walk_shield'

  -- TODO make a function on the player entity that does this for us
  local playerPressedActionButton = false
  for _, button in ipairs(self.shield:getUseButtons()) do
    if self.player.pressedActionButtons[button] then
      playerPressedActionButton = true
      break
    end
  end

  -- check for beginning shield blocking
  if self.shield:isButtonDown()
       and not playerPressedActionButton
       and (self.player:getWeaponState() == nil or self.player:getWeaponState():getType() == 'player_push_state')
    then
    self.subStateMachine:beginState(ShieldState.blocking)
  end
end

function PlayerShieldState:onBeginBlockingState()
  self.stateParameters.canPush = false
  self.player:stopPushing()

  -- TODO play shield sound
  if self.shield:getLevel() == 1 then
    self.stateParameters.animations.default = 'idle_shield_block'
    self.stateParameters.animations.move = 'walk_shield_block'
  else
    self.stateParameters.animations.default = 'idle_shield_large_block'
    self.stateParameters.animations.move = 'walk_shield_large_block'
  end

  -- tell shield entity to start blocking
  self.shield:startBlocking()
end

function PlayerShieldState:onUpdateBlockingState()
  -- check if button was released
  if not self.shield:isButtonDown() then
    self.subStateMachine:beginState(ShieldState.notBlocking)
    return
  end
end

function PlayerShieldState:onBegin()
  self.subStateMachine:initializeOnState(ShieldState.notBlocking)
end

function PlayerShieldState:update()
  self.subStateMachine:update()
end

return PlayerShieldState