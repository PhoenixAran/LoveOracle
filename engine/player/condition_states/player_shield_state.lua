local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local PlayerState = require 'engine.player.player_state'

local ShieldState = {
  notBlocking = 1,
  blocking = 2
}

-- TODO finish implementing

---@class PlayerShieldState : PlayerState
---@field shieldState integer
---@field shield ItemShield
local PlayerShieldState = Class { __includes = PlayerState,
  init = function(self, args)
    PlayerState.init(self, args)
    self.shieldState = ShieldState.notBlocking
  end
}

function PlayerShieldState:getType()
  return 'player_shield_state'
end

function PlayerShieldState:onBegin()

end 

function PlayerShieldState:update()

end

function PlayerShieldState:onBeginNotBlockingState()
  self.shieldState = ShieldState.notBlocking
  self.stateParameters.canPush = true
  
  -- set the player's default animation
  if self.shield:getLevel() == 1 then
    self.stateParameters.animations.default = 'idle_shield'
    self.stateParameters.animations.move = 'walk_shield'
  else
    self.stateParameters.animations.default = 'idle_shield_large'
    self.stateParameters.animations.move = 'walk_shield_large'
  end

  if not self.shield:isEquipped() then
    self.shield:unequip()
  end
end

function PlayerShieldState:onUpdateNotBlockingState()
    -- set the player's default animation
  if self.shield:getLevel() == 1 then
    self.stateParameters.animations.default = 'idle_shield'
    self.stateParameters.animations.move = 'walk_shield'
  else
    self.stateParameters.animations.default = 'idle_shield_large'
    self.stateParameters.animations.move = 'walk_shield_large'
  end

  local playerPressedActionButton = false
  for _, button in ipairs(self.shield:getUseButtons()) do
    if self.player.pressedActionButtons[button] then
      playerPressedActionButton = true
      break
    end
  end

  if self.shield:isButtonDown()
       and not playerPressedActionButton
       and (self.player:getWeaponState() == nil or self.player:getWeaponState():getType() == 'player_push_state')
    then
    self:onBeginBlockingState()
  end
end

function PlayerShieldState:onBeginBlockingState()

end



return PlayerShieldState