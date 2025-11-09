local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local lume = require 'lib.lume'
local InspectorProperties = require 'engine.entities.inspector_properties'
local TablePool = require 'engine.utils.table_pool'
local Input = require('engine.singletons').input
local vector = require 'engine.math.vector'
local BumpBox = require 'engine.entities.bump_box'
local Pool = require 'engine.utils.pool'
local SpriteBank = require 'engine.banks.sprite_bank'
local MapEntity = require 'engine.entities.map_entity'
local Collider = require 'engine.components.collider'
local PlayerStateMachine = require 'engine.player.player_state_machine'
local PlayerStateParameters = require 'engine.player.player_state_parameters'
local PlayerMovementController = require 'engine.player.player_movement_controller'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local Physics = require 'engine.physics'
local Consts = require 'constants'
local PlayerSkills = require 'engine.player.player_skills'
local bit = require 'bit'
local EntityDebugDrawFlags = require('engine.enums.flags.entity_debug_draw_flags').enumMap
local CollisionTag = require 'engine.enums.collision_tag'
local Interactions = require 'engine.entities.interactions'


-- ### STATES ###
-- control states
local PlayerLedgeJumpState = require 'engine.player.control_states.player_ledge_jump_state'
local PlayerRespawnDeathState = require 'engine.player.control_states.player_respawn_death_state'
-- condition states
local PlayerBusyState = require 'engine.player.condition_states.player_busy_state'
local PlayerHitstunState = require 'engine.player.condition_states.player_hitstun_state'
-- environment states
local PlayerGrassEnvironmentState = require 'engine.player.environment_states.player_grass_environment_state'
local PlayerSwimEnvironmentState = require 'engine.player.environment_states.player_swim_environment_state'
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
---@field ledgeJumpQueryRect table
---@field ledgeJumpQueryRectTargets table
---@field ledgeJumpQueryRectFilter function
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
    self:setCollidesWithLayer({'tile', 'ledge_jump'})
    self.collisionTag = CollisionTag.player

    -- hitbox
    self.hitbox:resize(6, 9)
    self.hitbox:setCollisionTag(self.collisionTag)

    -- tile collision
    self:setCollisionTiles('wall')
    
    -- ground observer
    self.groundObserver:setOffset(0, 4)

    -- components
    self.playerMovementController = PlayerMovementController(self, self.movement)
    self.sprite = SpriteBank.build('player', self)
    self.spriteFlasher:addSprite(self.sprite)

    -- set up sprite squisher
    self.spriteSquisher:addSpriteRenderer(self.sprite)

    -- states
    self.environmentStateMachine = PlayerStateMachine(self)
    self.controlStateMachine = PlayerStateMachine(self)
    self.weaponStateMachine = PlayerStateMachine(self)
    self.conditionStateMachines = {}
    self.stateParameters = nil

    self.stateCollection = {
      -- condition states
      -- control states
      ['player_ledge_jump_state'] = PlayerLedgeJumpState(self),
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
      if not self:actionUseItem('x') then
        self:actionStroke('x')
      end
    end)
    self:addPressInteraction('a', function(player)
      -- TODO interact
      self.playerMovementController:jump()
    end)
    self:addPressInteraction('b', function(player)
      self:actionUseItem('b')
    end)
    self:addPressInteraction('y', function(player)
      self:actionUseItem('y')
    end)

    self.items = {
      ['a'] = nil,
      ['b'] = nil
    }

    -- entity sprite effect configuration
    self.shadowOffsetY = 6
    self.rippleOffsetY = 6
    self.shadowVisible = true

    -- signal connections
    self.movement:connect('landed', self, '_onLanded')

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

    self.ledgeJumpQueryRect = {
      x = 0,
      y = 0,
      w = 2,
      h = 2
    }

    self.ledgeJumpQueryRectTargets = {
      [Direction4.left] = {
        x = -5 - self.ledgeJumpQueryRect.w / 2,
        y = 0 - self.ledgeJumpQueryRect.h / 2
      },
      [Direction4.right] = {
        x = 5 - self.ledgeJumpQueryRect.w / 2,
        y = 0 - self.ledgeJumpQueryRect.h / 2,
      },
      [Direction4.up] = {
        x = 0 - self.ledgeJumpQueryRect.w / 2,
        y = -6 - self.ledgeJumpQueryRect.h / 2
      },
      [Direction4.down] = {
        x = 0 - self.ledgeJumpQueryRect.w / 2,
        y = 6 - self.ledgeJumpQueryRect.h / 2
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
          if other:isTopTile() then
            if bit.band(item.collisionTiles, other.tileData.tileType) == 0 then
              return nil
            end
            return responseName
          end
          return nil
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
          if item:isTopTile() then
            return bit.band(playerInstance.collisionTiles, item.tileData.tileType) ~= 0
          end
          return false
        end
        return true
      end
      return false
    end

    -- set up tile query rect filter that is used when determining if the player is pushing a tile
    self.tileQueryRectFilter = function(item)
      if canCollide(playerInstance, item) then
        if item.isTile and item:isTile() and item:isTopTile() then
          return bit.band(playerInstance.collisionTiles, item.tileData.tileType) ~= 0
        end
        return bit.band(PhysicsFlags:get('push_block').value, item.physicsLayer) ~= 0
      end
      return false
    end

    -- set up ledge jump query filter
    self.ledgeJumpQueryRectFilter = function(item)
      if canCollide(playerInstance, item) then
        return item.getType and item:getType() == 'ledge_jump'
      end
      return false
    end

    -- set interactions TODO
  end
}

function Player:getType()
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
  respawnDeathState['waitForAnimation'] = not instant
  self:beginControlState(respawnDeathState)
end

function Player:respawn()
  self:setPosition(self.respawnPositionX, self.respawnPositionY)
  Physics:update(self, self.x, self.y)
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

-- player specific state stuff
function Player:isSwimming()
  local enviromentState = self.environmentStateMachine:getCurrentState()
  if enviromentState then
    return enviromentState:getType() == 'player_swim_environment_state'
  end
  return false
end

function Player:onHazardTile()
  return self.groundObserver.inHole 
         or (self.groundObserver.inWater and not self.skills.canSwimInWater)
         or (self.groundObserver.inLava and not self.skills.canSwimInLava)
         -- TODO ocean swimming check?
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
    return self:getStateFromCollection('player_swim_environment_state')
  elseif go.inWater then
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

function Player:updateStates()
  self:integrateStateParameters()

  -- update weapon state
  self.weaponStateMachine:update()
  -- update environment state
  self.environmentStateMachine:update()
  self:requestNaturalState()

  -- update control state
  self.controlStateMachine:update()

  -- update condition states
  for i = lume.count(self.conditionStateMachines), 1, -1 do
    self.conditionStateMachines[i]:update()
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
-- TODO unequip
---@param item Item
function Player:equipItem(item)
  self:addChild(item)
  item:setPlayer(self)
  for i, v in ipairs(item.useButtons) do
    self.items[v] = item
  end
  item:awake()
end

function Player:updateEquippedItems()
  for _, item in pairs(self.items) do
    item:update()
    if item:isUsable() then
      if item:isButtonDown() then
        item:onButtonDown()
      end
    end
  end
end

-- actions

--- calls the item:onButtonPress callback for the given mapped button
---@param button string
function Player:actionUseItem(button)
  local item = self.items[button]
  if item ~= nil and item:isUsable() then
    if item:onButtonPressed() then
      self:emit('entity_item_used', item)
      return true
    end
  end
  return false
end

function Player:actionStroke(button)
  if self:isSwimming() and self.playerMovementController:canStroke() then
    self.playerMovementController:stroke()
    return true
  end
  return false
end

function Player:interruptItems()
  for _, item in pairs(self.items) do
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
  -- TODO play sound
  local activeStates = self:getActiveStates()
  for _, state in ipairs(activeStates) do
    state:onHurt(damageInfo)
  end
  TablePool.free(activeStates)
  self:beginConditionState(PlayerHitstunState())
end

function Player:_onLanded()
  -- TODO play sound
  -- print 'player landed!'
  self.spriteSquisher:wiggle(.1)
end

function Player:checkRoomTransitions()
  if (self:getStateParameters().canRoomTransition or self:getStateParameters().canAutoRoomTransition) and not self:onHazardTile() then
    for _, other in ipairs(self.moveCollisions) do
      if other:getType() == 'room_edge' then
        ---@type RoomEdge
        local roomEdge = other
        if self:getStateParameters().canAutoRoomTransition then
          roomEdge:requestRoomTransition(self:getPosition())
        elseif roomEdge.canRoomTransition then
          if roomEdge:canRoomTransition(self:getDirection8()) then
            roomEdge:requestRoomTransition(self:getPosition())
          end
        end
      end
    end
  end
end

---query physics world with ledge jump rect
---@return any[] items
---@return integer len
function Player:queryLedgeJumpRect()
  local x,y,w,h = self.ledgeJumpQueryRect.x, self.ledgeJumpQueryRect.y, self.ledgeJumpQueryRect.w, self.ledgeJumpQueryRect.h
  x, y = vector.add(x, y, self:getPosition())
  local items, len = Physics:queryRect(x,y,w,h, self.ledgeJumpQueryRectFilter)
  return items, len
end

-- TODO make the ledgejump and tilepush detection stuff into a component
--- will start a ledge jump state if the player is able to
function Player:updateLedgeJumpState()
  if self:getStateParameters().canLedgeJump then
    local movementDirection4 = self.movement:getDirection4()
    local animDirection = self.animationDirection4
    local vectorTable = self.ledgeJumpQueryRectTargets[animDirection]
    self.ledgeJumpQueryRect.x, self.ledgeJumpQueryRect.y = vectorTable.x, vectorTable.y
    if movementDirection4 == animDirection then
      local items, len = self:queryLedgeJumpRect()
      if len > 0 then
        ---@type LedgeJump
        local ledgeJumpEntity = lume.first(items)
        local dir4 = ledgeJumpEntity:getDirection4()
        local dir8 = self:getDirection8()
        local px, py = self:getPosition()
        if ledgeJumpEntity:canLedgeJump(px, py, dir8) then
          local playerLedgeJumpState = self:getStateFromCollection('player_ledge_jump_state')
          playerLedgeJumpState.direction4 = ledgeJumpEntity:getDirection4()
          self:beginControlState(playerLedgeJumpState)
        end
      end
      Physics.freeTable(items)
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
      for _, pushTile in ipairs(items) do
        if pushTile:isTopTile() then
          local playerPushState = self:getStateFromCollection('player_push_state')
          playerPushState.pushTile = pushTile
          self:beginWeaponState(playerPushState)
          break
        end
      end
      Physics.freeTable(items)
    end
  end
end

function Player:stopPushing()
  local weaponState = self:getWeaponState()
  if weaponState == self:getStateFromCollection('player_push_state') then
    weaponState:endState()
  end
  self:integrateStateParameters()
  self:setVector(0, 0)
  self.playerMovementController:chooseAnimation()
  if self:isOnGround() and not self.stateParameters.canControlOnGround then
    self.sprite:play(self.stateParameters.animations.default)
  end
end

function Player:onAwake()
  self.roomEdgeCollisionBox:entityAwake()
  self.hitbox:entityAwake()
end

---gets active states. Be sure to return table to table pool when you are done with it
---@return PlayerState[]
function Player:getActiveStates()
  local activeStates = TablePool.obtain()

  if self.controlStateMachine:isActive() then
    lume.push(activeStates, self.controlStateMachine:getCurrentState())
  end
  if self.weaponStateMachine:isActive() then
    lume.push(activeStates, self.weaponStateMachine:getCurrentState())
  end
  if self.environmentStateMachine:isActive() then
    lume.push(activeStates, self.environmentStateMachine:getCurrentState())
  end
  for _, stateMachine in ipairs(self.conditionStateMachines) do
    if stateMachine:isActive() then
      lume.push(activeStates, stateMachine:getCurrentState())
    end
  end

  return activeStates
end

function Player:update()
  self.previousPositionX, self.previousPositionY = self.x, self.y
  -- pre-state update
  self.groundObserver:update()
  self:requestNaturalState()
  self.playerMovementController:update()
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

  self:updateEquippedItems()
  self:updateEntityEffectSprite()

  self.spriteFlasher:update()
  self.spriteSquisher:update()
  self.sprite:update()
  self.combat:update()
  self.hitbox:update()
  self.movement:update()

  local tvx, tvy = self:move()

  -- check ledge jumping
  if self:getWeaponState() == nil then
    self:updateLedgeJumpState()
  end

  -- check push tile if we are not ledge jumping
  local EPSILON = 0.001
  if tvx == 0 and tvy == 0 then
    local movementDir8 = self.movement:getDirection8()
    if movementDir8 == Direction8.up or movementDir8 == Direction8.down
      or movementDir8 == Direction8.left or movementDir8 == Direction8.right then
      --check if we are pushing a tile or we are pushing against a ledge jump
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

  MapEntity.draw(self)

  for _, item in pairs(self.items) do
    if item.drawAbove and item:isVisible() then
      item:drawAbove()
    end
  end
end

function Player:onEnterRoom()
  local activeStates = self:getActiveStates()
  for _, state in ipairs(activeStates) do
    state:onEnterRoom()
  end
  TablePool.free(activeStates)
end

function Player:onLeaveRoom()
  local activeStates = self:getActiveStates()
  for _, state in ipairs(activeStates) do
    state:onLeaveRoom()
  end
  TablePool.free(activeStates)

  -- TODO jump and land events
end

--- debug draw
---@param entDebugDrawFlags integer
function Player:debugDraw(entDebugDrawFlags)
  MapEntity.debugDraw(self, entDebugDrawFlags)
  if bit.band(entDebugDrawFlags, EntityDebugDrawFlags.RoomBox) ~= 0 then
    self.roomEdgeCollisionBox:debugDraw()
  end
  if lume.any(self.items) then
    for _, item in pairs(self.items) do
      item:debugDraw(entDebugDrawFlags)
    end
  end
end

function Player:getInspectorProperties()
  local props = Entity.getInspectorProperties(self)
  props:setGroup('States')
  props:addReadOnlyString('Environment',
    ---@param player Player
    function(player)
      if player.environmentStateMachine:isActive() then
        return player.environmentStateMachine:getCurrentState():getType()
      end
      return ''
    end, 
    true
  )
  props:addReadOnlyString('Control',
    function(player)
      if player.controlStateMachine:isActive() then
        return player.controlStateMachine:getCurrentState():getType()
      end
      return ''
    end, 
    true
  )
  props:addReadOnlyString('Weapon',
    function(player)
      if player.weaponStateMachine:isActive() then
        return player.weaponStateMachine:getCurrentState():getType()
      end
      return ''
    end, 
    true
  )
  props:addReadOnlyString('Conditions',
    function(player)
      local str = ''
      if lume.any(self.conditionStateMachines) then
        for _, stateMachine in ipairs(player.conditionStateMachines) do
          if stateMachine:isActive() then
            str = str .. stateMachine:getCurrentState():getType() .. ','
          end
        end
      end
      return str
    end,
    true
  )
  return props
end

return Player

