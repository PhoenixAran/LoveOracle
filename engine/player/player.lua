local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local lume = require 'lib.lume'
local Input = require('engine.singletons').input
local vector = require 'lib.vector'
local BumpBox = require 'engine.entities.bump_box'
local Pool = require 'engine.utils.pool'
local SpriteBank = require 'engine.banks.sprite_bank'
local MapEntity = require 'engine.entities.map_entity'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local Collider = require 'engine.components.collider'
local Raycast = require 'engine.components.raycast'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local PlayerStateMachine = require 'engine.player.player_state_machine'
local PlayerStateParameters = require 'engine.player.player_state_parameters'
local PlayerMovementController = require 'engine.player.player_movement_controller'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local Physics = require 'engine.physics'
local Consts = require 'constants'
local PlayerSwimEnvironmentState = require 'engine.player.environment_states.player_swim_environment_state'
local PlayerRespawnDeathState = require 'engine.player.control_states.player_respawn_death_state'
local PlayerSkills = require 'engine.player.player_skills'
-- ### STATES ###
-- condition states
local PlayerBusyState = require 'engine.player.condition_states.player_busy_state'
local PlayerHitstunState = require 'engine.player.condition_states.player_hitstun_state'
-- environment states
local PlayerGrassEnvironmentState = require 'engine.player.environment_states.player_grass_environment_state'
local PlayerJumpEnvironmentState = require 'engine.player.environment_states.player_jump_environment_state'
-- weapon states
local PlayerSwingState = require 'engine.player.weapon_states.swing_states.player_swing_state'
local PlayerPushState = require 'engine.player.weapon_states.player_push_state'

---@class Player : MapEntity
---@field roomEdgeCollisionBox Collider
---@field playerMovementController PlayerMovementController
---@field environmentStateMachine PlayerStateMachine
---@field controlStateMachine PlayerStateMachine
---@field weaponStateMachine PlayerStateMachine
---@field conditionStateMachines PlayerStateMachine[]
---@field stateParameters PlayerStateParameters
---@field stateCollection table<string, any>
---@field skills PlayerSkills
---@field useDirectionX number
---@field userDirectionY number
---@field useDirection4 Direction4
---@field pressedActionButtons string[]
---@field buttonCallbacks table<string, function[]>
---@field respawnPositionX number
---@field respawnPositionY number
---@field respawnDirection4 number
---@field moveAnimation string
---@field items table<string, Item?>
---@field previousPositionX number
---@field previousPositionY number
---@field respawnIndexX integer
---@field respawnIndexY integer
---@field slideAndCornerCorrectQueryRectFilter function
---@field tileQueryRect table
---@field tileQueryRectTargets table
---@field tileQueryRectFilter function
local Player = Class { __includes = MapEntity,
  ---@param self Player
  ---@param args table
  init = function(self, args)
    args.w, args.h = 8, 10
    args.direction = args.direction or Direction4.down
    args.name = 'player'
    MapEntity.init(self, args)
    -- signals
    self:signal 'respawn'


    -- player skills
    self.skills = PlayerSkills(args.skills)

    -- room edge collision
    self.roomEdgeCollisionBox = Collider(self, {
      x = -12 / 2,
      y = -13 / 2,
      w = 12,
      h = 13,
      offsetX = 0,
      offsetY = -2 
    })
    self.roomEdgeCollisionBox:setCollidesWithLayer('room_edge')
    self:setCollidesWithLayer('tile')
    -- tile collision
    self:setCollisionTile('wall')
    
    -- ground observer
    self.groundObserver:setOffset(0, 4)

    -- components
    self.playerMovementController = PlayerMovementController(self, self.movement)
    self.sprite = SpriteBank.build('player', self)
    self.spriteFlasher:addSprite(self.sprite)

    -- states
    self.environmentStateMachine = PlayerStateMachine(self)
    self.controlStateMachine = PlayerStateMachine(self)
    self.weaponStateMachine = PlayerStateMachine(self)
    self.conditionStateMachines = {}
    self.stateParameters = nil

    self.stateCollection = {
      -- condition states
      -- control states
      ['player_respawn_death_state'] = PlayerRespawnDeathState(self),
      -- environment states
      ['player_grass_environment_state'] = PlayerGrassEnvironmentState(self),
      ['player_jump_environment_state'] = PlayerJumpEnvironmentState(self),
      ['player_swim_environment_state'] = PlayerSwimEnvironmentState(self),
      -- weapon states
      ['player_swing_state'] = PlayerSwingState(self),
      ['player_push_state'] = PlayerPushState(self),
    }
    
    -- use direction variables are useful for finding what way player
    -- is holding dpad when they are not allowed to move (like during a sword swing)
    -- if the player can move, it will match the direction they are moving in
    self.useDirectionX, self.useDirectionY = 0, 0
    -- I don't see a usecase for Direction8 version for Use Direction
    -- If they need that much control they already have the vector values for direction,
    -- and if they need an animation Direction4 should be enough
    self.useDirection4 = Direction4.none

    self.pressedActionButtons = {}
    self.buttonCallbacks = {}

    self.respawnPositionX, self.respawnPositionY = nil, nil
    self.respawnDirection4 = Direction4.down
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
      --damageInfo.damage = 1
      --damageInfo.hitstunTime = 8
      --damageInfo.knockbackTime = 8
      --damageInfo.knockbackSpeed = 80
      --damageInfo.sourceX, damageInfo.sourceY = player:getPosition()
      --local rx = lume.random(-20, 20)
      --local ry = lume.random(-20, 20)
      --damageInfo.sourceX = damageInfo.sourceX + rx
      --damageInfo.sourceY = damageInfo.sourceY + ry
      --player:hurt(damageInfo)
      player:startRespawnControlState()
      error('test')
    end)

    self.items = {
      ['a'] = nil,
      ['b'] = nil
    }

    -- entity sprite effect configuration
    self.shadowOffsetY = 6
    self.shadowVisible = true

    -- signal connections
    self.health:connect('healthDepleted', self, '_onHealthDepleted')

    self.tileQueryRect = {
      x = 0,
      y = 0,
      w = 2,
      h = 2
    }
    self.tileQueryRectTargets = {
      [Direction4.left] = {
        x = -5 - self.tileQueryRect.w / 2,
        y = 0 - self.tileQueryRect.h / 2
      },
      [Direction4.right] = {
        x = 5 - self.tileQueryRect.w / 2,
        y = 0 - self.tileQueryRect.h / 2,
      },
      [Direction4.up] = {
        x = 0 - self.tileQueryRect.w / 2,
        y = -6 - self.tileQueryRect.h / 2
      },
      [Direction4.down] = {
        x = 0 - self.tileQueryRect.w / 2,
        y = 6 - self.tileQueryRect.h / 2
      }
    }

    -- declarations
    self.previousPositionX = 0
    self.previousPositionY = 0

    -- put debug stuff here
    self.health:setMaxHealth(9999999999, true)


    -- set up Bump callbacks
    local canCollide = require('engine.entities.bump_box').canCollide
    local playerInstance = self
    -- set up filter to be used for world:move()
    self.moveFilter = function(item, other)
      local responseName = 'slide'
      -- make sure item is the player because we use the same filter for our room edge collision box
      if item:getStateParameters().autoCorrectMovement then
        responseName = 'slide_and_corner_correct'
      end
      if canCollide(item, other) then
        if other.isTile and other:isTile() then
          if bit.band(item.collisionTiles, other.tileData.tileType) == 0 then
            return nil
          end
        end
        return responseName
      end
      return nil
    end
    -- set up queryRect filter that is used when the response is slide_and_corner_correct
    self.slideAndCornerCorrectQueryRectFilter = function(item)
      if item == playerInstance or item == self.roomEdgeCollisionBox then
        return false
      end
      if canCollide(playerInstance, item) then
        if item.isTile and item:isTile() then
          return bit.band(playerInstance.collisionTiles, item.tileData.tileType) ~= 0
        end
        return true
      end
      return false
    end

    -- set up tile query rect filter that is used when determining if the player is pushing a tile
    self.tileQueryRectFilter = function(item)
      if canCollide(playerInstance, item) then
        if item.isTile and item:isTile() then
          return bit.band(playerInstance.collisionTiles, item.tileData.tileType) ~= 0
        end
        return bit.band(PhysicsFlags:get('push_block').value, item.physicsLayer)
      end
      return false
    end
  end
}

function Player:getType()
  return 'player'
end

function Player:getCollisionTag()
  return 'player'
end

function Player:getSkills()
  return self.skills
end

---matches animation direction with a given vector
---@param inputX number
---@param inputY number
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

function Player:markRespawn()
  self.respawnPositionX, self.respawnPositionY = self:getPosition()
  self.respawnDirection4 = self:getAnimationDirection4()
end

---@param instant boolean
function Player:startRespawnControlState(instant)
  if instant == nil then
    instant = false
  end
  local respawnDeathState = self:getStateFromCollection('player_respawn_death_state')
  respawnDeathState['waitForAnimation'] = instant
  self:beginControlState(respawnDeathState)
end

function Player:respawn()
  self:setPosition(self.respawnPositionX, self.respawnPositionY)
  self:setAnimationDirection4(self.respawnDirection4)
  self:setVector(0, 0)
  self:setZPosition(0)
  self:setZVelocity(0)
  self:emit('respawn')
end

--- update use direction vector
function Player:updateUseDirections()
  local direction4 = Direction4.none
  local x, y = 0, 0
  -- find Direction4
  if Input:down('up') then
    direction4 = Direction4.up
  elseif Input:down('down') then
    direction4 = Direction4.down
  elseif Input:down('left') then
    direction4 = Direction4.left
  elseif Input:down('right') then
    direction4 = Direction4.right
  end

  --- now get actual x y values
  if Input:down('up') then
    y = y - 1
  end
  if Input:down('down') then
    y = y + 1
  end
  if Input:down('left') then
    x = x - 1
  end
  if Input:down('right') then
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

--- return use Direction4 enum value
---@return any
function Player:getUseDirection4()
  return self.useDirection4
end

--- return use direction vector value
---@return number useDirectionX
---@return number useDirectionY
function Player:getUseDirection()
  return self.useDirectionX, self.useDirectionY
end

--- add an event for when a gamepad key is pressed
--- usually used to add item use events
---@param key string
---@param func function
function Player:addPressInteraction(key, func)
  if self.buttonCallbacks[key] == nil then
    self.buttonCallbacks[key] = {}
  end
  lume.push(self.buttonCallbacks[key], func)
end

--- check if any key press events need to be invoked
---@param key string
---@return boolean if event was called
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

--- return current player state parameters
---@return PlayerStateParameters
function Player:getStateParameters()
  return self.stateParameters
end

-- gets the desired state from state cache collection
function Player:getStateFromCollection(name)
  return self.stateCollection[name]
end

---return current weapon state (if there is any)
---@return PlayerState | nil
function Player:getWeaponState()
  return self.weaponStateMachine:getCurrentState()
end

---return player animation table
---@return table<string, string>
function Player:getPlayerAnimations()
  return self.stateParameters.animations
end

---@param state PlayerState
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

---@param conditionType string
function Player:hasConditionState(conditionType)
  for _, conditionState in ipairs(self.conditionStateMachines) do
    if conditionState:isActive() and conditionState:getType() == conditionType then
      return true
    end
  end
  return false
end

---@param conditionType string
function Player:endConditionState(conditionType)
  for _, conditionState in ipairs(self.conditionStateMachines) do
    if conditionState:isActive() and conditionState.currentState:getType() == conditionType then
      conditionState.currentState:endState()
      break
    end
  end
end

-- begin a new weapon state, replacing the previous weapon state
---@param state PlayerState
function Player:beginWeaponState(state)
  self.weaponStateMachine:beginState(state)
end

-- begin a new constrol state, replacing the previuos control state
---@param state PlayerState
function Player:beginControlState(state)
  self.controlStateMachine:beginState(state)
end

function Player:endControlState()
  if self.controlStateMachine:isActive() then
    self.controlStateMachine.currentState:endState()
  end
end

-- begin a new environment state, replacing the previous environment state
---@param state PlayerEnvironmentState
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
---@return PlayerEnvironmentState?
function Player:getDesiredNaturalState()
  -- get ground observer
  local go = self.groundObserver
  if go.inGrass then
    return self:getStateFromCollection('player_grass_environment_state')
  elseif self:isInAir() then
    return self:getStateFromCollection('player_jump_environment_state')
  elseif go.inLava then
    return nil -- TODO lava thing
  elseif go.inDeepWater then
    return self:getStateFromCollection('player_swim_environment_state')
  end
  -- TODO implement rest of environment states
  return nil
end

-- begin a new busy condition state with the specified duration
-- and optional specified animation
---@param duration integer
---@param animation string?
function Player:beginBusyState(duration, animation)
  if animation == nil then
    animation = self.sprite:getCurrentAnimationKey() 
  end
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
    if self.playerMovementController:isMoving() and
        self.sprite:getCurrentAnimationKey() ~= self:getPlayerAnimations().move then
      self.sprite:play(self:getPlayerAnimations().move)
    elseif not self.playerMovementController:isMoving() and
        self.sprite:getCurrentAnimationKey() ~= self:getPlayerAnimations().default then
      self.sprite:play(self:getPlayerAnimations().default)
    end
  end
end

-- equip the given item
---@param item Item
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

--- calls the item:onButtonPress callback for the given mapped button
---@param button string
function Player:actionUseItem(button)
  local item = self.items[button]
  if item ~= nil and item:isUsable() then
    return item:onButtonPressed()
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
      stateMachine:getCurrentState():endState()
    end
  end
  if self.weaponStateMachine:isActive() then
    self.weaponStateMachine:getCurrentState():onInterruptItems()
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
        ---@type RoomEdge
        local roomEdge = other
        if roomEdge.canRoomTransition then
          if roomEdge:canRoomTransition(self:getDirection8()) then
            roomEdge:requestRoomTransition(self:getPosition())
          end
        end
      end
    end
  end
end

---query physics world with push tile rect
---@return any[] items
---@return integer len
function Player:queryPushTileRect()
  local x,y,w,h = self.tileQueryRect.x,self.tileQueryRect.y,self.tileQueryRect.w, self.tileQueryRect.h
  x,y = vector.add(x,y, self:getPosition())
  local items, len = Physics:queryRect(x,y,w,h, self.tileQueryRectFilter)
  return items, len
end

--- will start a push tile state if the player is able to
function Player:updatePushTileState()
  if self:getStateParameters().canPush then
    local movementDirection4 = self.movement:getDirection4()
    local animDirection = self.animationDirection4
    local vectorTable = self.tileQueryRectTargets[animDirection]
    self.tileQueryRect.x, self.tileQueryRect.y = vectorTable.x, vectorTable.y
    if movementDirection4 == animDirection then
      local items, len = self:queryPushTileRect()
      if len > 0 then
        local pushTile = lume.first(items)
        local playerPushState = self:getStateFromCollection('player_push_state')
        playerPushState.pushTile = pushTile
        self:beginWeaponState(playerPushState)
      end
      Physics.freeTable(items)
    end
  end
end

function Player:onAwake()
  self.roomEdgeCollisionBox:entityAwake()
end

function Player:update(dt)
  self.previousPositionX, self.previousPositionY = self.x, self.y
  -- pre-state update
  self.groundObserver:update(dt)
  self:requestNaturalState()
  self.playerMovementController:update(dt)
  self:updateUseDirections()

  self.pressedActionButtons['a'] = false
  self.pressedActionButtons['b'] = false
  self.pressedActionButtons['x'] = false
  self.pressedActionButtons['y'] = false

  if Input:pressed('a') then
    self.pressedActionButtons['a'] = self:checkPressInteractions('a')
  end
  if Input:pressed('b') then
    self.pressedActionButtons['b'] = self:checkPressInteractions('b')
  end
  if Input:pressed('x') then
    self.pressedActionButtons['x'] = self:checkPressInteractions('x')
  end
  if Input:pressed('y') then
    self.pressedActionButtons['y'] = self:checkPressInteractions('y')
  end

  self:integrateStateParameters()
  self:requestNaturalState()
  
  -- update states
  self:updateStates()

  self:updateEquippedItems(dt)
  self:updateEntityEffectSprite(dt)

  self.spriteFlasher:update(dt)
  self.sprite:update(dt)
  self.combat:update(dt)
  self.movement:update(dt)

  local tvx, tvy = self:move(dt)
  --check if we are pushing a tile
  local EPSILON = 0.001
  if math.abs(tvx) < EPSILON and math.abs(tvy) < EPSILON then
    local movementDir8 = self.movement:getDirection8()
    if movementDir8 == Direction8.up or movementDir8 == Direction8.down
    or movementDir8 == Direction8.left or movementDir8 == Direction8.right then
      local currentWeaponState = self:getWeaponState()
      if currentWeaponState == nil then
        self:updatePushTileState()
      end
    end
  end
  
  self:checkRoomTransitions()
end

function Player:draw()
  for _, item in pairs(self.items) do
    if item.drawBelow and item:isVisible() then
      item:drawBelow()
    end
  end
  local grassEffectPlaying = self.effectSprite:getCurrentAnimationKey() == 'grass'
  if self.effectSprite:isVisible() and not grassEffectPlaying then
    self.effectSprite:draw()
  end
  if self.sprite:isVisible() then
    self.sprite:draw()
  end
  if self.effectSprite:isVisible() and grassEffectPlaying then
    self.effectSprite:draw()
  end
  for _, item in pairs(self.items) do
    if item.drawAbove and item:isVisible() then
      item:drawAbove()
    end
  end
end

function Player:debugDraw()
  Entity.debugDraw(self)
  self.roomEdgeCollisionBox:debugDraw()
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
