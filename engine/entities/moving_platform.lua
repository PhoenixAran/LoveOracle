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
local function parsePathScript(loopType, script, initialX, initialY)
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
  if loopType == LoopType.PingPong then
    local cnt = lume.count(commands)
    local inverseCommands = { }
    for i = cnt, 1, -1 do
      lume.push(inverseCommands, commands[i]:getInverse())
    end

    for _, cmd in ipairs(inverseCommands) do
      lume.push(commands, cmd)
    end
  end
  if lume.count(commands) == 0 then
    love.log.warn('Spawning platform without path script')
  end
  return commands
end



---@class MovingPlatform : Entity
---@field pathCommands PlatformPathCommand[]
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
    self.pathCommands = parsePathScript(LoopType[args.loopType], args.pathScript, args.x + (args.w / 2), args.y + (args.h / 2))
    -- TODO add via tiled args
    self.spriteRenderer = SpriteBank.build('1x2_platform', self)
    self.speed = 25
    self.pingPongState = PingPongState.Forwards

    self.commandIndex = 1
    self.currentCommandSetUp = false
    self.currentCommandComplete = false
    self.currentPauseTime = 0
  end
}

function MovingPlatform:getType()
  return 'moving_platform'
end

function MovingPlatform:update(dt)
  -- execute current command
  if lume.any(self.pathCommands) then
    local currentCommand = self.pathCommands[self.commandIndex]
    if not self.currentCommandComplete then
      if currentCommand.commandType == PlatformPathCommandType.Move then
        if not self.currentCommandSetUp then
          local x, y = self:getPosition()
          self.targetX, self.targetY = vector.add(x, y, vector.mul(GRID_SIZE, currentCommand.moveX, currentCommand.moveY))
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
      self.commandIndex = (self.commandIndex % lume.count(self.pathCommands)) + 1
    end
  end
end

function MovingPlatform:moveTowards(dt, targetX, targetY)
  local diffX, diffY = vector.sub(targetX, targetY, self:getPosition())
  local normX, normY = vector.normalize(diffX, diffY)
  local velX, velY = vector.mul(self.speed * dt, normX, normY)
  velX, velY = self.horizontalClamp(velX, diffX), self.verticalClamp(velY, diffY)

  local x, y = self:getPosition()
  self:setPosition(x + velX, y + velY)
  Physics:update(self, self.x, self.y)

  return math.abs(targetX - x) <= EPSILON and math.abs(targetY - y) <= EPSILON
end

function MovingPlatform:draw()
  self.spriteRenderer:draw()
end

return MovingPlatform