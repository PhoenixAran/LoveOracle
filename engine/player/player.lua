local Class = require 'lib.class'
local GameEntity = require 'engine.entities.game_entity'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local PlayerStateMachine = require 'engine.player.player_state_machine'
local PlayerStateParameters = require 'engine.player.player_state_parameters'
local PlayerBusyState = require 'engine.player.condition_states.player_busy_state'
local lume = require 'lib.lume'

local Player = Class { __includes = GameEntity,
  init = function(self, enabled, visible, rect) 
    GameEntity.init(self, enabled, visible, rect)
    
    -- components
    local prototypeSprite = PrototypeSprite(.3, 0, .7, 16, 16)
    -- uncomment this when the player sprite is ready
    -- self.sprite = spriteBank.build('player')
    
    
    -- declarations
    self.animDirection = 'down'
    
    self.stateCollection = { }
    self.environmentStateMachine = PlayerStateMachine(self)
    self.controlStateMachine = PlayerStateMachine(self)
    self.weaponStateMachine = PlayerStateMachine(self)
    self.conditionStateMachines = { }
    self.stateParameters = nil
    
    self.useDirectionX, self.useDirectionY = 0
    self.respawnPositionX, self.respawnPositionY = nil, nil
    self.respawnDirection = nil
    self.moveAnimation = nil
  
    -- add components
    self:add(SpriteRenderer(prototypeSprite))
  end
}

-- this is made obsolete with animation substrips
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

-- gets the desired state from state cache collection
function Player:getStateFromCollection(name)
  return self.stateCollection[name]
end

function Player:getWeaponState()
  return self.weaponStateMachine:getCurrentState()
end

function Player:getPlayerAnimations()
  return self.stateParameters.playerAnimations
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
  self.environmentState:beginState(state)
end

-- try to switch to a natural state
function Player:requestNaturalState()
  local desiredNaturalState = self:getDesiredNaturalState()
  self.environmentState:beginState(desiredNaturalState)
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

function Player:updateStates()
  -- prestate update
  self:requestNaturalState()
  
end

function Player:update(dt)
  GameEntity.update(self, dt)
  self:updateStates()
end


return Player
