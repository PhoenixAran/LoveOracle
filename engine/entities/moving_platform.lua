local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local EntityDrawType = require 'engine.enums.entity_draw_type'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local parse = require 'engine.utils.parse_helpers'
local SpriteBank = require 'engine.banks.sprite_bank'
local GRID_SIZE = require('constants').GRID_SIZE

local PlatformPathCommandType = {
  Move = 'move',
  Pause = 'pause'
}

local LoopType = {
  Cycle = 0,
  PingPong = 1
}

local PingPongState = {
  Forwards = 0,
  Backwards = 1
}

local CommandExecuteState = {
  InProgress = 0,
  Complete = 1
}

---@class PlatformPathCommand
---@field commandType string
---@field moveX integer tile indexes to move by vertically
---@field moveY integer tile indexes to move by vertically
---@field pauseTime integer amount of ticks this platform should stay still for
local PlatformPathCommand = Class {
  init = function(self, commandType, arg1, arg2)
    self.commandType = commandType
    if commandType == PlatformPathCommandType.Move then
      self.moveX = arg1
      self.moveY = arg2
    elseif commandType == PlatformPathCommandType.Pause then
      self.pauseTime = arg1
    end
  end
}

local SEMICOLON_TOKEN = ';'
--- compiles script path into array of PlatformPathCommand objects
---@param script string
---@return PlatformPathCommand[]
local function parsePathScript(script)
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
      lume.push(commands, PlatformPathCommand(commandType, parts[1], parts[2]))
    elseif commandType == PlatformPathCommandType.Pause then
      assert(parse.argIsInteger(parts[2]), 'Expected integer argument 1 in pause command. Error script: ' .. script)
      lume.push(commands, PlatformPathCommand(commandType, parts[1]))
    else
      error('Invalid path command given: ' .. line)
    end
  end
  if lume.count(commands) == 0 then
    love.log.warn('Spawning platform without path script')
  end
  return commands
end

function PlatformPathCommand:getType()
  return 'platform_path_command'
end

---@class MovingPlatform : Entity
---@field pathCommands PlatformPathCommand[]
---@field spriteRenderer SpriteRenderer
---@field loopType integer
---@field speed number
---@field idleDuration number
---@field commandIndex number
---@field pingPongState number
---@field commandState number
local MovingPlatform = Class { __includes = Entity,
  init = function(self, args)
    args.drawType = EntityDrawType.background
    Entity.init(self, args)
    if args.loopType ~= 'Cycle' and args.loopType ~= 'PingPong' then
      love.log.warn('Invalid looptype "' .. args.loopType .. '" given to MovingPlatform object. Defaulting to Cycle loopType')
      args.loopType = 'Cycle'
    end
    self.pathCommands = parsePathScript(args.pathScript)
    self.loopType = LoopType[args.loopType]

    -- TODO add via tiled args
    self.spriteRenderer = SpriteBank.build('1x2_platform', self)
    self.speed = 3
    self.idleDuration = 1
    self.pingPongState = PingPongState.Forwards

    self.commandIndex = 1
    self.commandState = CommandExecuteState.Complete
  end
}

function MovingPlatform:getType()
  return 'moving_platform'
end

function MovingPlatform:update()
  -- execute current command
  local currentCommand = self.pathCommands[self.commandIndex]
  

  -- change current command index if required
  if self.commandState == CommandExecuteState.Complete then
    if self.loopType == LoopType.Cycle then
      self.commandIndex = ((self.commandIndex - 1) % #self.pathCommands) + 1
    elseif self.loopType == LoopType.PingPong then
      if self.pingPongState == PingPongState.Forwards then
        if self.commandIndex < #self.pathCommands then
          self.commandIndex = self.commandIndex + 1
        elseif self.commandIndex == #self.pathCommands then
          self.commandIndex = self.commandIndex - 1
          self.pingPongState = PingPongState.Backwards
        end
      else
        if self.commandIndex > 1 then
          self.commandIndex = self.commandIndex - 1
        else
          self.commandIndex = 1
          self.pingPongState = PingPongState.Forwards
        end
      end
    end
    self.commandState = CommandExecuteState.InProgress
  end 
end

function MovingPlatform:draw()
  self.spriteRenderer:draw()
end

return MovingPlatform