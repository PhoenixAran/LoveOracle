local Class = require 'lib.class'
local GameEntity = require 'engine.entities.game_entity'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local PlayerStateMachine = require 'engine.player.player_state_machine'
local PlayerStateParameters = require 'engine.player.player_state_parameters'
local PlayerBusyState = require 'engine.player.condition_states.player_busy_state'
local PlayerMovementController = require 'engine.player.player_movement_controller'
local lume = require 'lib.lume'

local Player = Class { __includes = GameEntity,
  init = function(self, enabled, visible, rect) 
    GameEntity.init(self, enabled, visible, rect)    
    -- components
    self.playerMovementController = PlayerMovementController(self, self.movement)
    -- uncomment this when the player sprite is ready
    self.sprite = spriteBank.build('player')
    
    
    -- declarations
    self.stateCollection = { }
    self.environmentStateMachine = PlayerStateMachine(self)
    self.controlStateMachine = PlayerStateMachine(self)
    self.weaponStateMachine = PlayerStateMachine(self)
    self.conditionStateMachines = { }
    self.stateParameters = nil
    
    self.useDirectionX, self.useDirectionY = 0
    self.pressedActionButtons = { }
    self.buttonCallbacks = { }
    
    self.respawnPositionX, self.respawnPositionY = nil, nil
    self.respawnDirection = nil
    self.moveAnimation = nil
  
    -- add components
    self:add(self.sprite)
  end
}

-- obsolete
function Player:matchAnimationDirection(inputX, inputY)
  local direction = self.animDirection
  if inputX == -1 and inputY == -1 and direction ~= 'up' and direction ~= 'left' then
    direction = 'up'
  elseif inputX == 1 and inputY == 1 and direction ~= 'down' and direction ~= 'right' then
    direction = 'down'
  elseif inputX == 1 and inputY == -1 and direction ~= 'up' and direction ~= 'right' then
    direction = 'up'
  elseif inputX == -1 and inputY == 1 and direction ~= 'down' and direction ~= 'left' then
    direction = 'left'
  elseif inputX == 0 and inputY == -1 and direction ~= 'up' then
    direction = 'up'
  elseif inputX == 0 and inputY == 1 and direction ~= 'down' then 
    direction = 'down'
  elseif inputX == -1 and inputY == 0 and direction ~= 'left' then
    direction = 'left'
  elseif inputX == 1 and inputY == 0 and direction ~= 'right' then
    direction = 'right'
  end
  self.animDirection = direction
end

function Player:updateUseDirections()
  local x, y = 0, 0
  if input:down('up') then
    y = y + 1
  end
  if input:down('down') then
    y = y - 1
  end
  if input:down('left') then
    x = x - 1
  end
  if input:down('right') then
    x = x + 1
  end
  if self.playerMovementController:isMoving() and self:getStateParameters().canStrafe then
    self.useDirectionX = self.playerMovementController.directionX
    self.useDirectionY = self.playerMovementController.directionY
  else
    self.useDirectionX = x
    self.useDirectionY = y
  end
end

function Player:checkPressInteractions(key)
  local callbacks = self.buttonCallbacks[key]
  for _, func in self.buttonCallbacks do
    if func(key) then
      return true
    end
  end
  return false
end

function Player:getStateParameters()
  return self.stateParameters
end

-- gets the desired state from state cache collection
function Player:getStateFromCollection(name)
  return self.stateCollection[name]
end

function Player:getWeaponState()
  return self.weaponStateMachine:getCurrentState()
end

function Player:getPlayerAnimations()
  return self.stateParameters.animations
end

function Player:beginConditionState(state)
  local count = lume.count(self.conditionStatesMachines)
  for i = count, 1, -1 do
    if not self.conditionStateMachines[i]:isActive() then
      table.remove(self.conditionStateMachines, i)
    end
  end
  
  local stateMachine = PlayerStateMachine(self)
  lume.push(self.conditionStateMachines, stateMachine)
  stateMachine:beginState(state)
end

function Player:hasConditionState(conditionType)
  for _, conditionState in ipairs(self.conditionStateMachines) do
    if conditionState:isActive() and conditionState:getType() == conditionType then
      return true
    end
  end
  return false
end

function Player:endConditionState(conditionType)
  for _, conditionState in ipairs(self.conditionStateMachines) do
    if conditionState:isActive() and conditionState:getType() == conditionType then
      conditionState:endState()
      break
    end
  end
end

-- begin a new weapon state, replacing the previous weapon state
function Player:beginWeaponState(state)
  self.weaponStateMachine:beginState(state)
end

-- begin a new constrol state, replacing the previuos control state
function Player:beginControlState(state)
  self.controlStateMachine:beginState(state)
end

function Player:endControlState()
  if self.controlStateMachine:isActive() then
    self.controlStateMachine.state:endState()
  end
end

-- begin a new environment state, replacing the previous environment state
function Player:beginEnvironmentState(state)
  self.environmentStateMachine:beginState(state)
end

-- try to switch to a natural state
function Player:requestNaturalState()
  local desiredNaturalState = self:getDesiredNaturalState()
  self.environmentStateMachine:beginState(desiredNaturalState)
  self:integrateStateParameters()
end

-- return the player environment state that the player wants to be in
-- based on his current surface and jumping state
function Player:getDesiredNaturalState()
  -- get ground observer
  local go = self.groundObserver
  if go.inGrass then
    return self:getStateFromCollection('environmentstategrass')
  end
  -- TODO implement rest of environment states
  
  return nil
end

-- begin a new busy condition state with the specified duration
-- and optional specified animation
function Player:beginBusyState(duration, animation)
  if animation == nil then animation = self.sprite:getCurrentAnimationKey() end
  if self:getWeaponState() == nil then
    -- should i check if the current animation is the same? not sure yet
    self.sprite:play(animation)
  end
  local busyState = PlayerBusyState(self, duration, animation)
  self:beginConditionState(busyState)
  return busyState
end

-- combine all state parameters in each active state
function Player:integrateStateParameters()
  self.stateParameters = PlayerStateParameters()
  self.stateParameters.animations.default = 'idle'
  self.stateParameters.animations.aim = 'aim'
  self.stateParameters.animations.throw = 'throw'
  self.stateParameters.animations.swing = 'swing'
  self.stateParameters.animations.swingNoLunge = 'swingNoLunge'
  self.stateParameters.animations.swingBig = 'swingBig'
  self.stateParameters.animations.spin = 'spin'
  self.stateParameters.animations.stab = 'stab'
  self.stateParameters.animations.carry = 'carry'
  for _, conditionStateMachine in ipairs(self.conditionStateMachines) do
    if conditionStateMachine:isActive() then
      self.stateParameters:integrateParameters(conditionStateMachine:getStateParameters())
    end
  end
  self.stateParameters:integrateParameters(self.environmentStateMachine:getStateParameters())
  self.stateParameters:integrateParameters(self.controlStateMachine:getStateParameters())
  self.stateParameters:integrateParameters(self.weaponStateMachine:getStateParameters())
end

function Player:updateStates(dt)
  
  -- update weapon state
  self.weaponStateMachine:update(dt)
  -- update environment state  
  self.environmentStateMachine:update(dt)
  self:requestNaturalState()
  
  -- update control state
  self.controlStateMachine:update(dt)
  
  -- update condition states
  for i = lume.count(self.conditionStateMachines), 1, -1 do
    self.conditionStateMachines[i]:update(dt)
    if not self.conditionStates[i]:isActive() then
      table.remove(self.conditionStates, i)
    end
  end
  
  -- play the default animation
  if self:isOnGround() and self.stateParameters.canMoveOnGround then
    self.sprite.play(self:getPlayerAnimations().default)
  end
end

function Player:update(dt)
  -- TODO? determine if we update components before or after all the crap below
  GameEntity.update(self, dt)
  
  -- pre-state update
  self:requestNaturalState()
  self.playerMovementController:update(dt)
  
  self:updateUseDirections()
    -- TODO add x and y action buttons
  self.pressedActionButtons['a'] = false
  self.pressedActionButtons['b'] = false
  if input:down('a') then
    self.pressedActionButtons['a'] = self:checkPressInteractions('a')
  end
    if input:down('b') then
    self.pressedActionButtons['b'] = self:checkPressInteractions('a')
  end
  
  self:integrateStateParameters()
  self:requestNaturalState()
  
  self:updateStates()
  
  self:setVector(self.useDirectionX, self.useDirectionY)
  self:move(dt)
  --TODO update equipped items
end


return Player
