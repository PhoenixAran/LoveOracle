local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local BumpBox = require 'engine.entities.bump_box'
local Pool = require 'engine.utils.pool'
local SpriteBank = require 'engine.utils.sprite_bank'
local MapEntity = require 'engine.entities.map_entity'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local Collider = require 'engine.components.collider'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local PlayerStateMachine = require 'engine.player.player_state_machine'
local PlayerStateParameters = require 'engine.player.player_state_parameters'
local PlayerMovementController = require 'engine.player.player_movement_controller'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
-- ### STATES ###
-- condition states
local PlayerBusyState = require 'engine.player.condition_states.player_busy_state'
local PlayerHitstunState = require 'engine.player.condition_states.player_hitstun_state'
-- environment states
local PlayerJumpEnvironmentState = require 'engine.player.environment_states.player_jump_environment_state'
-- weapon states
local PlayerSwingState = require 'engine.player.weapon_states.swing_states.player_swing_state'

local Player = Class { __includes = MapEntity,
  init = function(self, name, enabled, visible, position)
    MapEntity.init(self,name, enabled, visible, { x = position.x, y = position.y,  w = 8, h = 9 })  
    -- room edge collision 
    --self.roomEdgeCollisionBox = BumpBox((position.x - 12 / 2), (position.y - 13 / 2), 12, 9)
    local ex, ey = self:getPosition()
    self.roomEdgeCollisionBox = Collider(self, true, {
      x = ex - 12/2,
      y = ey - 13/2,
      w = 12,
      h = 12,
      offsetX = 0,
      offsetY = -2,
    })
    self.roomEdgeCollisionBox:setCollidesWithLayer('room_edge')

    -- components
    self.playerMovementController = PlayerMovementController(self, self.movement)
    self.sprite = SpriteBank.build('player', self)
    self.spriteFlasher:addSprite(self.sprite)
    
    -- states
    self.environmentStateMachine = PlayerStateMachine(self)
    self.controlStateMachine = PlayerStateMachine(self)
    self.weaponStateMachine = PlayerStateMachine(self)
    self.conditionStateMachines = { }
    self.stateParameters = nil
    
    self.stateCollection = { 
      -- environment states
      ['player_jump_environment_state'] = PlayerJumpEnvironmentState(self),
      -- weapon states
      ['player_swing_state'] = PlayerSwingState(self),
    }
    
    -- use direction variables are useful for finding what way player
    -- is holding dpad when they are not allowed to move (like during a sword swing)
    -- if the player can move, it will match the direction they are moving in
    self.useDirectionX, self.useDirectionY = 0, 0
    -- I don't see a usecase for Direction8 version for Use Direction
    -- If they need that much control they already have the vector values for direction,
    -- and if they need an animation Direction4 should be enough
    self.useDirection4 = self.animationDirection4 or Direction4.none

    self.pressedActionButtons = { }
    self.buttonCallbacks = { }
    
    self.respawnPositionX, self.respawnPositionY = nil, nil
    self.respawnDirection = nil
    self.moveAnimation = nil
  
    -- bind controls (except dpad, thats automatically done)
    self:addPressInteraction('x', function(player) 
      self.playerMovementController:jump()
    end)
    self:addPressInteraction('a', function(player)
      self:actionUseItem('a')
    end)
    self:addPressInteraction('b', function(player)
      self:actionUseItem('b')
    end)
    self:addPressInteraction('y', function(player)
      local damageInfo = require('engine.entities.damage_info')()
      damageInfo.damage = 3
      damageInfo.hitstunTime = 8
      damageInfo.knockbackTime = 8
      damageInfo.knockbackSpeed = 80
      damageInfo.sourceX, damageInfo.sourceY = player:getPosition()
      local rx = lume.random(-20, 20)
      local ry = lume.random(-20, 20)
      damageInfo.sourceX = damageInfo.sourceX + rx
      damageInfo.sourceY = damageInfo.sourceY + ry
      player:hurt(damageInfo)
    end)
  
    self.items = { 
      a = nil,
      b = nil
    }
    
    -- entity sprite effect configuration
    self.effectSprite:setOffset(0, 6)
    self.shadowVisible = true
    
  end
}

function Player:getType()
  return 'player'
end

function Player:getCollisionTag()
  return 'player'
end

function Player:matchAnimationDirection(inputX, inputY)
  if inputX == 0 and inputY == 0 then
    return
  end
  local animDir4 = self.animationDirection4
  -- we want to use Direction8 because of 8-way direction
  -- then man handle how to convert Direction8 to Direction4
  local dir8 = Direction8.getDirection(inputX, inputY)
  if dir8 == Direction8.right and animDir4 ~= Direction4.right then
    animDir4 = Direction4.right
  elseif dir8 == Direction8.upRight and animDir4 ~= Direction4.right and animDir4 ~= Direction4.up then
    animDir4 = Direction4.up
  elseif dir8 == Direction8.up and animDir4 ~= Direction4.up then
    animDir4 = Direction4.up
  elseif dir8 == Direction8.upLeft and animDir4 ~= Direction4.left and animDir4 ~= Direction4.up then
    animDir4 = Direction4.up
  elseif dir8 == Direction8.left and animDir4 ~= Direction4.left then
    animDir4 = Direction4.left
  elseif dir8 == Direction8.downLeft and animDir4 ~= Direction4.left and animDir4 ~= Direction4.down then
    animDir4 = Direction4.down
  elseif dir8 == Direction8.down and animDir4 ~= Direction4.down then
    animDir4 = Direction4.down
  elseif dir8 == Direction8.downRight and animDir4 ~= Direction4.down and animDir4 ~= Direction4.right then
    animDir4 = Direction4.down
  end
  self:setAnimationDirection4(animDir4)
end

function Player:updateUseDirections()
  local direction4 = Direction4.none
  local x, y = 0, 0
  -- find Direction4
  if input:down('up') then
    direction4 = Direction4.up
  elseif input:down('down') then
    direction4 = Direction4.down
  elseif input:down('left') then
    direction4 = Direction4.left
  elseif input:down('right') then
    direction4 = Direction4.right
  end
  
  --- now get actual x y values
  if input:down('up') then
    y = y - 1
  end
  if input:down('down') then
    y = y + 1
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
    -- movement controller sets self.animationDirection4 via self:setAnimationDirection4 according to playerMovementController.directionX
    -- and playerMovementController.directionY
    -- so we use self.animationDirection4
    self.useDirection4 = self.animationDirection4
  else
    self.useDirectionX = x
    self.useDirectionY = y
    self.useDirection4 = direction4
  end
end

function Player:getUseDirection4()
  return self.useDirection4
end

function Player:getUseDirectionXY()
  return self.useDirectionX, self.useDirectionY
end

function Player:addPressInteraction(key, func)
  if self.buttonCallbacks[key] == nil then
    self.buttonCallbacks[key] = { }
  end
  lume.push(self.buttonCallbacks[key], func)
end

function Player:checkPressInteractions(key)
  local callbacks = self.buttonCallbacks[key]
  if callbacks ~= nil then
    for _, func in pairs(callbacks) do
      if func(self) then
        return true
      end
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
  local count = lume.count(self.conditionStateMachines)
  for i = count, 1, -1 do
    if not self.conditionStateMachines[i]:isActive() then
      local conditionStateMachine = self.conditionStateMachines[i]
      table.remove(self.conditionStateMachines, i)
      Pool.free(conditionStateMachine)
    end
  end
  local stateMachine = Pool.obtain('player_state_machine')
  stateMachine:setPlayer(self)
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
    return self:getStateFromCollection('player_grass_environment_state')
  elseif self:isInAir() then
    return self:getStateFromCollection('player_jump_environment_state')
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
  if self.stateParameters ~= nil then
    Pool.free(self.stateParameters)
  end
  self.stateParameters = Pool.obtain('player_state_parameters')
  self.stateParameters.animations.default = 'idle'
  self.stateParameters.animations.move = 'walk'
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
  self:integrateStateParameters()
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
    if not self.conditionStateMachines[i]:isActive() then
      table.remove(self.conditionStateMachines, i)
    end
  end
  
  self:integrateStateParameters()

  -- play the move animation
  if self:isOnGround() and self.stateParameters.canControlOnGround then
    if self.playerMovementController:isMoving() and self.sprite:getCurrentAnimationKey() ~= self:getPlayerAnimations().move then
      self.sprite:play(self:getPlayerAnimations().move)
    elseif not self.playerMovementController:isMoving() and self.sprite:getCurrentAnimationKey() ~= self:getPlayerAnimations().default then
      self.sprite:play(self:getPlayerAnimations().default)
    end
  end
end

function Player:equipItem(item)
  self:addChild(item)
  item:setPlayer(self)
  for i, v in ipairs(item.useButtons) do
    self.items[v] = item
  end
end

function Player:updateEquippedItems(dt)
  for key, item in pairs(self.items) do
    item:update(dt)
    if item:isUsable() then
      if item:isButtonDown() then
        item:onButtonDown()
      end
    end
  end
end

function Player:actionUseItem(button)
  local item = self.items[button]
  if item ~= nil and item:isUsable() then
    return item:onButtonPress()
  end
  return false
end

function Player:interruptItems()
  for k, item in pairs(self.items) do
    item:interrupt()
  end
  if self.controlStateMachine:isActive() then
    self.controlStateMachine:getCurrentState():onInterruptItems()
  end
  if self.weaponStateMachine:isActive() then
    self.weaponStateMachine:getCurrentState():onInterruptItems()
  end
  if self.environmentStateMachine:isActive() then
    self.environmentStateMachine:getCurrentState():onInterruptItems()
  end
  for _, stateMachine in ipairs(self.conditionStateMachines) do
    if stateMachine:isActive() then
      stateMachine:getCurrentState():onInterruptItems()
    end
  end
  if self.weaponStateMachine:isActive() then
    self.weaponStateMachine:getCurrentState():endState()
  end
  self:integrateStateParameters()
end

function Player:onHurt(damageInfo)
  self:beginConditionState(PlayerHitstunState())
end

function Player:checkRoomTransitions()
  if self:getStateParameters().canRoomTransition then
    for _, other in ipairs(self.moveCollisions) do
      if other:getType() == 'room_edge' then
        if other.canRoomTransition then
          if other:canRoomTransition(self:getDirection8()) then
            other:requestRoomTransition(self:getPosition())
          end
        end
      end
    end
  end
end

function Player:update(dt)
  -- pre-state update
  self:requestNaturalState()
  self.playerMovementController:update(dt)
  self:updateUseDirections()

  self.pressedActionButtons['a'] = false
  self.pressedActionButtons['b'] = false
  self.pressedActionButtons['x'] = false
  self.pressedActionButtons['y'] = false
  
  if input:pressed('a') then
    self.pressedActionButtons['a'] = self:checkPressInteractions('a')
  end
  if input:pressed('b') then
    self.pressedActionButtons['b'] = self:checkPressInteractions('b')
  end
  if input:pressed('x') then
    self.pressedActionButtons['x'] = self:checkPressInteractions('x')
  end
  if input:pressed('y') then
    self.pressedActionButtons['y'] = self:checkPressInteractions('y')
  end
  
  self:integrateStateParameters()
  self:requestNaturalState()
  self:updateStates()
  self:move(dt)
  self:updateEquippedItems(dt)
  self:updateEntityEffectSprite(dt)

  self.spriteFlasher:update(dt)
  self.sprite:update(dt)
  self.combat:update(dt)
  self.movement:update(dt)

  self:checkRoomTransitions()
end

function Player:draw()
  local oldScale = love.graphics.getScale
  for _, item in pairs(self.items) do
    if item.drawBelow then 
      item:drawBelow()
    end
  end
  if self.effectSprite:isVisible() then
    self.effectSprite:draw()
  end
  if self.sprite:isVisible() then
    self.sprite:draw()
  end
  for _, item in pairs(self.items) do
    if item.drawAbove then
      item:drawAbove()
    end
  end
end

function Player:getInspectorProperties()
  local props = MapEntity.getInspectorProperties(self)
  props:addReadOnlyString('Animated Sprite Key', function()
      local textValue = self.sprite:getCurrentAnimationKey()
      if self.sprite:getSubstripKey() ~= nil then
        textValue = textValue .. '[' .. self.sprite:getSubstripKey() .. ']'
      end
      return textValue
  end, false)
  return props
end

return Player
