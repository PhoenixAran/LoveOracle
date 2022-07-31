local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local lume = require 'lib.lume'
local Input = require('engine.singletons').input
local vector = require 'lib.vector'
local BumpBox = require 'engine.entities.bump_box'
local Pool = require 'engine.utils.pool'
local SpriteBank = require 'engine.utils.sprite_bank'
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
-- ### STATES ###
-- condition states
local PlayerBusyState = require 'engine.player.condition_states.player_busy_state'
local PlayerHitstunState = require 'engine.player.condition_states.player_hitstun_state'
-- environment states
local PlayerJumpEnvironmentState = require 'engine.player.environment_states.player_jump_environment_state'
-- weapon states
local PlayerSwingState = require 'engine.player.weapon_states.swing_states.player_swing_state'

---@class Player : MapEntity
---@field roomEdgeCollisionBox Collider
---@field playerMovementController PlayerMovementController
---@field environmentStateMachine PlayerStateMachine
---@field controlStateMachine PlayerStateMachine
---@field weaponStateMachine PlayerStateMachine
---@field conditionStateMachines PlayerStateMachine[]
---@field stateParameters PlayerStateParameters
---@field stateCollection table<string, PlayerState|PlayerEnvironmentState>
---@field useDirectionX number
---@field userDirectionY number
---@field useDirection4 integer
---@field pressedActionButtons string[]
---@field buttonCallbacks table<string, function[]>
---@field respawnPositionX number
---@field respawnPositionY number
---@field respawnDirection number
---@field moveAnimation string
---@field items table<string, Item?>
---@field raycast1 Raycast
---@field raycast2 Raycast
---@field raycastTargetValues table<integer, table>
---@field raycastPositions table<integer, table<integer, table>>
---@field raycastDirection integer
---@field pushTileRaycast Raycast
---@field pushTileRaycastTargetValues table<integer, table>
local Player = Class { __includes = MapEntity,
  ---@param self Player
  ---@param args table
  init = function(self, args)
    args.w, args.h = 8, 10
    args.direction = args.direction or Direction4.down
    MapEntity.init(self, args)
    -- room edge collision
    self.roomEdgeCollisionBox = Collider(self, {
      x = -12/2,
      y = -13/2,
      w = 12,
      h = 12,
      offsetX = 0,
      offsetY = -2,
      detectOnly = true
    })
    self.roomEdgeCollisionBox:setCollidesWithLayer('room_edge')
    self:setCollidesWithLayer('tile')
    -- tile collision
    self:setCollisionTile({'wall'})

    -- components
    self.playerMovementController = PlayerMovementController(self, self.movement)
    self.sprite = SpriteBank.build('player', self)
    self.spriteFlasher:addSprite(self.sprite)
    self.raycast1 = Raycast(self)
    self.raycast1:setCollidesWithLayer('tile')
    self.raycast1:setCollisionTileExplicit(self.collisionTiles)
    self.raycast1:addException(self)
    self.raycast2 = Raycast(self)
    self.raycast2:setCollidesWithLayer('tile')
    self.raycast2:setCollisionTileExplicit(self.collisionTiles)
    self.raycast2:addException(self)
    self.pushTileRaycast = Raycast(self)
    self.pushTileRaycast:addException(self)
    self.pushTileRaycast:setCollidesWithLayer('push_block')

    
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
    self.respawnDirection = Direction4.down
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
      damageInfo.damage = 1
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
      ['a'] = nil,
      ['b'] = nil
    }

    -- entity sprite effect configuration
    self.effectSprite:setOffset(0, 6)
    self.shadowVisible = true

    -- signal connections
    self.health:connect('healthDepleted', self, '_onHealthDepleted')

    --raycast stuff for movement corner corrections
    self.raycastTargetValues = {
      [Direction4.left] = {
        x = -5,
        y = 0
      },
      [Direction4.right] = {
        x = 5,
        y = 0
      },
      [Direction4.up] = {
        x = 0,
        y = -5
      },
      [Direction4.down] = {
        x = 0,
        y = 10
      }
    }
    self.raycastPositions = {
      [1] = {
        [Direction4.left] = {
          normal = { x = 0, y = 0 },
          offset = { x = 0 , y = -4 }
        },
        [Direction4.right] = {
          normal = { x = 0, y = 0 },
          offset = { x = 0, y = -4 }
        },
        [Direction4.up] = {
          normal = { x = -2, y = 0 },
          offset = { x = -5, y = 0 }
        },
        [Direction4.down] = {
          normal = { x = -2, y = 0 },
          offset = { x = -5, y = 0 }
        }
      },
      [2] = {
        [Direction4.left] = {
          normal = { x = 0, y = 3},
          offset = { x = 0, y = 7}
        },
        [Direction4.right] = {
          normal = { x = 0, y = 3 },
          offset = { x = 0, y = 7 }
        },
        [Direction4.up] = {
          normal = { x = 2, y = 0 },
          offset = { x = 5, y = 0}
        },
        [Direction4.down] = {
          normal = { x = 2, y = 0 },
          offset = { x = 5, y = 0 }
        }
      }
    }
    self.raycastDirection = args.direction
    self.pushTileRaycastTargetValues = {
      [Direction4.left] = {
        x = -5,
        y = 0
      },
      [Direction4.right] = {
        x = 5,
        y = 0
      },
      [Direction4.up] = {
        x = 0,
        y = -5
      },
      [Direction4.down] = {
        x = 0,
        y = 8
      }
    }
    -- put debug stuff here
    self.health:setMaxHealth(9999999999, true)
 

  end
}

function Player:getType()
  return 'player'
end

function Player:getCollisionTag()
  return 'player'
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
function Player:getUseDirectionXY()
  return self.useDirectionX, self.useDirectionY
end

--- add an event for when a gamepad key is pressed
--- usually used to add item use events
---@param key string
---@param func function
function Player:addPressInteraction(key, func)
  if self.buttonCallbacks[key] == nil then
    self.buttonCallbacks[key] = { }
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
  end

  -- TODO implement rest of environment states
  return nil
end

-- begin a new busy condition state with the specified duration
-- and optional specified animation
---@param duration integer
---@param animation string?
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

  -- check for push state
  local currentWeaponState = self:getWeaponState()

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

---@param direction4 integer
---@return number x
---@return number y
function Player:getRaycastTargetValue(direction4)
  local vectorTable = self.raycastTargetValues[direction4]
  return vectorTable.x, vectorTable.y
end

---@param raycastNumber integer
---@param direction4 integer
---@param key string?
---@return number x
---@return number y
function Player:getRaycastPosition(raycastNumber, direction4, key)
  if key == nil then
    key = 'normal'
  end
  local vectorTable = self.raycastPositions[raycastNumber][direction4][key]
  return vectorTable.x, vectorTable.y
end

---@param forceMatch boolean?
function Player:updateRaycastPositions(forceMatch)
  if self.raycastDirection ~= self.movement:getDirection4() or forceMatch then
    self.raycastDirection = self.movement:getDirection4()
    self.raycast1:setOffset(self:getRaycastPosition(1, self.raycastDirection))
    self.raycast2:setOffset(self:getRaycastPosition(2, self.raycastDirection))
    self.raycast1:setCastTo(self:getRaycastTargetValue(self.raycastDirection))
    self.raycast2:setCastTo(self:getRaycastTargetValue(self.raycastDirection))
  end
end

---@param dt number delta time
---@param tvx number translation vector x
---@param tvy number translation vector y
---@return boolean movementCorrected 
function Player:updateMovementCorrection(dt, tvx, tvy)
  -- we are not allowed to auto correct movement in our current state
  if not self:getStateParameters().autoCorrectMovement then
    return false
  end
  local mx, my = self.movement:getVector()
  local mDirection = Direction4.getDirection(mx, my)
  -- we're not inputting a move, so exit out
  if mDirection == Direction4.none then
    return false
  end
  -- if the player's animation direction does not match their animation direction, dont correct
  -- movement or else stuff gets janky in certain cases when sliding against a wall
  if mDirection ~= self.animationDirection4 then
    return false
  end
  -- if the player is moving diagonally or switched directions or stopped moving,
  -- force update the raycast positions to their default state based on 
  -- which way the player is facing
  if tvx == 0 and tvy == 0 and mx == 0 and my == 0 then
    self:updateRaycastPositions(true)
    return false
  end
  self:updateRaycastPositions()

  -- the player can stop moving mid movement correction
  -- should resume movement correction when they start moving in the same direction 
  -- so just exit out at this point
  if mx == 0 and my == 0 then
    return false
  end

  local isStillCollidingWithWallTile = false
  for _, other in ipairs(self.moveCollisions) do
    if other:isTile() then
      local tileData = other.tileData
      if bit.band(tileData.tileType, self.collisionTiles) ~= 0 then
        isStillCollidingWithWallTile = true
      end
    end
  end
  -- this check means that the movement correction has been completed
  -- we then reset the raycast positions and exit out
  if not isStillCollidingWithWallTile then
    self:updateRaycastPositions(true)
    return false
  end

  -- manhandle slippery corner sliding so players dont get snagged on corners
  local newX, newY = 0, 0

  -- in each case we slide the opposite raycast to the end of the player's collision box
  -- so we know when to stop correcting the movement 
  local dir4 = Direction4.getDirection(self:getVector())
  
  if dir4 == Direction4.up then
    local corrected = false
    if not self.raycast1:linecast() then
      self.raycast1:setOffset(self:getRaycastPosition(1, dir4))
      self.raycast2:setOffset(self:getRaycastPosition(2, dir4, 'offset'))
      if self.raycast2:linecast() then
        newX = -1
        corrected = true
      end
    end
    if not corrected and not self.raycast2:linecast() then
      self.raycast2:setOffset(self:getRaycastPosition(2, dir4))
      self.raycast1:setOffset(self:getRaycastPosition(1, dir4, 'offset'))
      if self.raycast1:linecast() then
        newX = 1
      end
    end
  elseif dir4 == Direction4.down then
    local corrected = false
    if not self.raycast1:linecast() then
      self.raycast1:setOffset(self:getRaycastPosition(1, dir4))
      self.raycast2:setOffset(self:getRaycastPosition(2, dir4, 'offset'))
      if self.raycast2:linecast() then
        newX = -1
        corrected = true
      end
    end
    if not corrected and not self.raycast2:linecast() then
      self.raycast2:setOffset(self:getRaycastPosition(2, dir4))
      self.raycast1:setOffset(self:getRaycastPosition(1, dir4, 'offset'))
      if self.raycast1:linecast() then
        newX = 1
        corrected = true
      end
    end
  elseif dir4 == Direction4.left then
    local corrected = false
    if not self.raycast1:linecast() then
      self.raycast1:setOffset(self:getRaycastPosition(1, dir4))
      self.raycast2:setOffset(self:getRaycastPosition(2, dir4, 'offset'))
      if self.raycast2:linecast() then
        newY = -1
        corrected = true
      end
    end
    if not corrected and not self.raycast2:linecast() then
      self.raycast2:setOffset(self:getRaycastPosition(2, dir4))
      self.raycast1:setOffset(self:getRaycastPosition(1, dir4, 'offset'))
      if self.raycast1:linecast() then
        newY = 1
      end
    end
  elseif dir4 == Direction4.right then
    local corrected = false
    if not self.raycast1:linecast() then
      self.raycast1:setOffset(self:getRaycastPosition(1, dir4))
      self.raycast2:setOffset(self:getRaycastPosition(2, dir4, 'offset'))
      if self.raycast2:linecast() then
        newY = -1
        corrected = true
      end
    end
    if not corrected and not self.raycast2:linecast() then
      self.raycast2:setOffset(self:getRaycastPosition(2, dir4))
      self.raycast1:setOffset(self:getRaycastPosition(1, dir4, 'offset'))
      if self.raycast1:linecast() then
        newY = 1
      end
    end
  end
  -- if the player is not close enough to the edge to get corrected, just return out early
  if mx == newX and my == newY then
    self:updateRaycastPositions(true)
    return false
  end

  -- recalculate the movement now with our new values
  self.movement:setVector(newX, newY)
  -- rollback last movement
  self.movement:recalculateLinearVelocity(dt, newX, newY)
  -- move again
  self:move(dt)
  return true
end

--- will start a push tile state if the player is able to
--- assumes movement is not being corrected from Player:updateMovementCorrection method
function Player:updatePushTileRaycast()
  if self:getStateParameters().canPush then
    local movementDirection = self.movement:getDirection4()
    local animDirection = self.animationDirection4
    if movementDirection == animDirection then
      local vectorTable = self.pushTileRaycastTargetValues[movementDirection]
      local x, y = vectorTable.x, vectorTable.y
      self.pushTileRaycast:setCastTo(x, y)
      if self.pushTileRaycast:linecast() then
        local hits = self.pushTileRaycast.hits
        for k, v in ipairs(hits) do
          -- TODO
        end
      end
    end
  end
end

function Player:update(dt)
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
  self:updateStates()
  local tvx, tvy = self:move(dt)
  local movementCorrected = self:updateMovementCorrection(dt, tvx, tvy)
  -- check if we are pushing a tile
  if not movementCorrected then
    local currentWeaponState = self:getWeaponState()
    if currentWeaponState == nil then
      self:updatePushTileRaycast()
    end
  end

  self:updateEquippedItems(dt)
  self:updateEntityEffectSprite(dt)

  self.spriteFlasher:update(dt)
  self.sprite:update(dt)
  self.combat:update(dt)
  self.movement:update(dt)

  self:checkRoomTransitions()
end

function Player:draw()
  for _, item in pairs(self.items) do
    if item.drawBelow and item:isVisible() then
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
    if item.drawAbove and item:isVisible() then
      item:drawAbove()
    end
  end
  self.pushTileRaycast:debugDraw()
end

function Player:debugDraw()
  Entity.debugDraw(self)
  self.roomEdgeCollisionBox:debugDraw()
  self.raycast1:debugDraw()
  self.raycast2:debugDraw()
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
