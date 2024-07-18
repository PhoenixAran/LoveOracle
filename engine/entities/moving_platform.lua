local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local EntityDrawType = require 'engine.enums.entity_draw_type'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local parse = require 'engine.utils.parse_helpers'
local SpriteBank = require 'engine.banks.sprite_bank'
local GRID_SIZE = require('constants').GRID_SIZE
local EPSILON = require('constants').EPSILON
local Physics = require 'engine.physics'

local PlatformPathCommandType = {
  Move = 'move',
  Pause = 'pause',
  -- this is just a helper for Move command
  ReturnToInitialPosition = 'initial_position'
}

local LoopType = {
  Cycle = 0,
  PingPong = 1
}

local PingPongState = {
  Forwards = 0,
  Backwards = 1
}


---@class PlatformPathCommand
---@field commandType string
---@field moveX integer grid units to move by horizontally
---@field moveY integer grid units to move by vertically
---@field pauseTime integer amount of ticks this platform should stay still for
local PlatformPathCommand = Class {
  init = function(self, commandType, arg1, arg2)
    self.commandType = commandType
    if commandType == PlatformPathCommandType.Move then
      self.moveX = tonumber(arg1)
      self.moveY = tonumber(arg2)
    elseif commandType == PlatformPathCommandType.Pause then
      self.pauseTime = tonumber(arg1)
    end
  end
}

function PlatformPathCommandType:getType()
  return 'platform_path_command_type'
end

function PlatformPathCommand:getInverse()
  if self.commandType == PlatformPathCommandType.Move then
    return PlatformPathCommand(self.commandType, -self.moveX, -self.moveY)
  else
    return PlatformPathCommand(self.commandType, self.pauseTime)
  end
end


---this helps implement the ReturnToInitialPosition path command
---this gets all the movements, to help determine how much to move platform to get to it's initial spawn position
---@param commands PlatformPathCommand[]
---@param startIndex integer
---@param endIndex integer
---@return integer sumX
---@return integer sumY
local function sumAllGridUnitMovements(commands, startIndex, endIndex)
  local x, y  = 0, 0
  for i = startIndex, endIndex - 1, 1 do
    if commands[i].commandType == PlatformPathCommandType.Move then
      x = x + commands[i].moveX
      y = y + commands[i].moveY
    end
  end
  return x, y
end

local SEMICOLON_TOKEN = ';'
--- compiles script path into array of PlatformPathCommand objects
---@param script string
---@return PlatformPathCommand[]
local function parsePathScript(script, initialX, initialY)
  local commands = { }
  local scriptLines = parse.split(script, SEMICOLON_TOKEN)
  local parts = { }
  for i, line in ipairs(scriptLines) do
    if i == lume.count(scriptLines) then
      break
    end
    lume.clear(parts)
    for part in string.gmatch(line, '([^,%s]+)') do
      lume.push(parts, part)
    end
    local commandType = parts[1]
    if commandType == PlatformPathCommandType.Move then
      assert(parse.argIsInteger(parts[2]), 'Expected integer argument 1 in move command. Error script: ' .. script)
      assert(parse.argIsInteger(parts[3]), 'Expected integer argument 2 in move command. Error script: ' .. script)
      lume.push(commands, PlatformPathCommand(commandType, parts[2], parts[3]))
    elseif commandType == PlatformPathCommandType.Pause then
      assert(parse.argIsInteger(parts[2]), 'Expected integer argument 1 in pause command. Error script: ' .. script)
      lume.push(commands, PlatformPathCommand(commandType, parts[2]))
    elseif commandType == PlatformPathCommandType.ReturnToInitialPosition then
      local x, y = sumAllGridUnitMovements(commands, 1, i)
      lume.push(commands, PlatformPathCommand(PlatformPathCommandType.Move, -x, -y))
    else
      error('Invalid path command given: ' .. line)
    end
  end
  if lume.count(commands) == 0 then
    love.log.warn('Spawning platform without path script')
  end
  print(love.inspect(commands))
  return commands
end



---@class MovingPlatform : Entity
---@field loopType integer
---@field pathCommands PlatformPathCommand[]
---@field inversePathCommands PlatformPathCommand[] used when a pingpong type loop is selected
---@field spriteRenderer SpriteRenderer
---@field speed number
---@field idleDuration number
---@field commandIndex number
---@field pingPongState number
---@field commandState number
---@field targetX number
---@field targetY number
---@field currentPauseTime number
---@field currentCommandSetUp boolean
---@field currentCommandComplete boolean
---@field horizontalClamp function
---@field verticalClamp function
local MovingPlatform = Class { __includes = Entity,
  init = function(self, args)
    args.drawType = EntityDrawType.background
    args.useBumpCoords = true
    Entity.init(self, args)

    if args.loopType ~= 'Cycle' and args.loopType ~= 'PingPong' then
      love.log.warn('Invalid looptype "' .. args.loopType .. '" given to MovingPlatform object. Defaulting to Cycle loopType')
      args.loopType = 'Cycle'
    end

    self.pathCommands = parsePathScript(args.pathScript, args.x + (args.w / 2), args.y + (args.h / 2))
    -- TODO add via tiled args
    self.spriteRenderer = SpriteBank.build('1x2_platform', self)
    self.speed = 25
    self.pingPongState = PingPongState.Forwards
    self.loopType = LoopType[args.loopType]

    self.commandIndex = 1
    self.currentCommandSetUp = false
    self.currentCommandComplete = false
    self.targetX = 0
    self.targetY = 0
    self.horizontalClamp, self.verticalClamp = math.max, math.max
    self.currentPauseTime = 0
    self:setPhysicsLayer('moving_platform')
  end
}

function MovingPlatform:getType()
  return 'moving_platform'
end

function MovingPlatform:update()
  local dt = love.time.dt
  -- execute current command
  if lume.any(self.pathCommands) then
    local currentCommand = self.pathCommands[self.commandIndex]
    if not self.currentCommandComplete then
      if currentCommand.commandType == PlatformPathCommandType.Move then
        if not self.currentCommandSetUp then
          local x, y = self:getPosition()
          local moveX, moveY = currentCommand.moveX, currentCommand.moveY
          if self.loopType == LoopType.PingPong and self.pingPongState == PingPongState.Backwards then
            moveX = -moveX
            moveY = -moveY
          end
          self.targetX, self.targetY = vector.add(x, y, vector.mul(GRID_SIZE, moveX, moveY))
          
          self.horizontalClamp = x < self.targetX and math.min or math.max
          self.verticalClamp = y < self.targetY and math.min or math.max
          self.currentCommandSetUp = true
        end
        self.currentCommandComplete = self:moveTowards(dt, self.targetX, self.targetY)
      elseif currentCommand.commandType == PlatformPathCommandType.Pause then
        if not self.currentCommandSetUp then
          self.currentPauseTime = 0
          self.currentCommandSetUp = true
        end
        self.currentPauseTime = self.currentPauseTime + dt
        self.currentCommandComplete = self.currentPauseTime >= currentCommand.pauseTime
      end
    end

    if self.currentCommandComplete then
      self.currentCommandSetUp = false
      self.currentCommandComplete = false
      -- change current command index if required
      if self.loopType == LoopType.Cycle then
        self.commandIndex = (self.commandIndex % lume.count(self.pathCommands)) + 1
      elseif self.loopType == LoopType.PingPong then
        if self.pingPongState == PingPongState.Forwards then
          if self.commandIndex < lume.count(self.pathCommands) then
            self.commandIndex = self.commandIndex + 1
          elseif self.commandIndex == lume.count(self.pathCommands) then
            self.pingPongState = PingPongState.Backwards
          end
        else
          if self.commandIndex > 1 then
            self.commandIndex = self.commandIndex - 1
          else
            self.pingPongState = PingPongState.Forwards
          end
        end
      end
    end
  end
end

function MovingPlatform:calculateVelocity(dt, targetX, targetY)
  local diffX, diffY = vector.sub(targetX, targetY, self:getPosition())
  local normX, normY = vector.normalize(diffX, diffY)
  local velX, velY = vector.mul(self.speed * dt, normX, normY)
  velX, velY = self.horizontalClamp(velX, diffX), self.verticalClamp(velY, diffY)
  return velX, velY
end

function MovingPlatform:moveTowards(dt, targetX, targetY)
  local velX, velY = self:calculateVelocity(dt, targetX, targetY)
  local x, y = self:getPosition()
  self:setPosition(x + velX, y + velY)
  Physics:update(self, self.x, self.y) 
  return math.abs(targetX - x) <= EPSILON and math.abs(targetY - y) <= EPSILON
end

function MovingPlatform:getPlatformVelocity()
  if not lume.any(self.pathCommands) then
    return 0, 0
  end
  local currentCommand = self.pathCommands[self.commandIndex]
  if currentCommand.commandType == PlatformPathCommandType.Move then
    return self:calculateVelocity(love.time.dt, self.targetX, self.targetY)
  end
  return 0, 0
end


function MovingPlatform:draw()
  self.spriteRenderer:draw()
end

return MovingPlatform