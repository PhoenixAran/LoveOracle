local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local parse = require 'engine.utils.parse_helpers'

local PlatformPathCommandType = {
  Move = 'move',
  Pause = 'pause'
}

local LoopType = {
  Cycle = 0,
  PingPong = 1
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
---@field loopType integer
local MovingPlatform = Class { __includes = Entity,
  init = function(self, args)
    if args.loopType ~= 'Cycle' and args.loopType ~= 'PingPong' then
      error('Invalid looptype "' .. args.loopType .. '" given to MovingPlatform object')
    end
    self.pathCommands = parsePathScript(args.pathScript)
    print(love.inspect(self.pathCommands))
    self.loopType = LoopType[args.loopType]
  end
}

function MovingPlatform:getType()
  return 'moving_platform'
end


return MovingPlatform