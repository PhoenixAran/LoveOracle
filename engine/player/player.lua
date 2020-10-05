local Class = require 'lib.class'
local GameEntity = require 'engine.entities.game_entity'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local PlayerStateMachine = require 'data.player.player_state_machine'
local PlayerStateParameters = require 'data.player.player_state_parameters'

local Player = Class { __includes = GameEntity,
  init = function(self, enabled, visible, rect) 
    GameEntity.init(self, enabled, visible, rect)
    
    -- declarations
    self.animDirection = 'down'
    
    self.stateCollection = { }
    self.environmentStateMachine = PlayerStateMachine()
    self.controlStateMachine = PlayerStateMachine()
    self.weaponStateMachine = PlayerStateMachine()
    self.conditionStateMachines = { }
    self.stateParameters = nil
    
    self.useDirectionX, self.useDirectionY = 0
    self.respawnPositionX, self.respawnPositionY = nil, nil
    self.respawnDirection = nil
    self.moveAnimation = nil
  
    -- add components
    local prototypeSprite = PrototypeSprite(.3, 0, .7, 16, 16)
    self:add(SpriteRenderer(prototypeSprite))
  end
}

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

-- gets the desired state from player state collection
function Player:getState(name)
  return self.stateCollection[name]
end

function Player:beginConditionState(state)
  --TODO
end

function Player:hasConditionState(conditionType)
  --TODO
end

function Player:endConditionState(conditionType)
  --TODO
end

function Player:beginWeaponState(state)
  self.weaponStateMachine:beginState(state)
end

function Player:beginControlState(state)
  self.controlStateMachine:beginState(state)
end

function Player:endControlState()
  if self.controlStateMachine:isActive() then
    self.controlStateMachine.state:endState()
  end
end

function Player:beginEnvironmentState(state)
  self.environmentState:beginState(state)
end

function Player:beginBusyState(duration, animation)
  --TODO
end

function Player:requestNaturalState()
  local desiredNaturalState = self:getDesiredNaturalState()
  self.environmentState:beginState(desiredNaturalState)
  self:integrateStateParameters()
end

function Player:getDesiredNaturalState()
  -- get ground observer
  local go = self.groundObserver
  if go.inGrass then
    return self:getState('environmentstategrass')
  end
  -- TODO implement rest of environment states
  
  return nil
end

function Player:updateStates()
  -- prestate update
  self:requestNaturalState()
  
end

function Player:update(dt)
  GameEntity.update(self, dt)
end


return Player
