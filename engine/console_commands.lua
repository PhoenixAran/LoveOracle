local console = require 'lib.console'
local lume = require 'lib.lume'
local ParseHelpers = require 'engine.utils.parse_helpers'
local IMGUI_EXISTS = pcall(require, 'imgui')

--- Console Command. Sets or Gets timescale
---@param args table
function console.commands.timescale(args)
  local tick = require 'lib.tick'
  if tonumber(args) then
    tick.timescale = tonumber(args)
  else
    console.print('Current timescale: ' .. tostring(tick.timescale))
  end
end
console.help.timescale = {
  section = "Gameplay",
  "Sets the timescale if a number is given.",
  "If not, it will return the current timescale value"
}

--- Console Command. Toggles fullscreen mode
function console.commands.fullscreen()
  local wasFullscreen = love.window.getFullscreen()
  if not love.window.setFullscreen(not love.window.getFullscreen()) then
    console.print("Could not set fullscreen for some reason")
  else
    if wasFullscreen then
      love.resize(love.graphics.getDimensions())
    end
  end
end
console.help.fullscreen = {
  section = 'Graphics',
  'Toggles fullscreen'
}

function console.commands.dumplog()
  if love.log.outFile then
    love.log.trace('Log dumped via console command')
    love.log.dump()
    console.print(string.format('Log dumped to %s/%s', love.filesystem.getSaveDirectory(), tostring(love.log.outFile)))
  else
    console.print('No output file configured for logger')
  end
end
console.help.dumplog = {
  section = 'Debug',
  'Dumps log to file'
}

function console.commands.inspect(entityId)
  if entityId == nil  then
    console.print('Entity Id required')
    return
  end
  if not IMGUI_EXISTS then
    console.print('You must have a debug build to use this command')
    return
  end
  local singleton = require 'engine.singletons'
  local module = require 'engine.imgui_modules.runtime_inspector'
  local entities = singleton.roomControl:getEntities()
  entityId = entityId:gsub('%s+', '')
  local entity = entities:getByName(entityId)
  if entity then
    module.setup(entity)
    if not lume.find(singleton.imguiModules, module) then
      lume.push(singleton.imguiModules, module)
    end
  else
    console.print(('Could not find entity with id value %s'):format(entityId))
  end
end
console.help.inspect = {
  section = 'Gameplay Debug',
  'Shows debug menu for altering Entity properties during runtime'
}

function console.commands.memory()
  if not IMGUI_EXISTS then
    console.print('You must have a debug build to use this command')
    return
  end
  local singleton = require 'engine.singletons'
  local module = require 'engine.imgui_modules.memory_inspector'
  module.setup()
  if not lume.find(singleton.imguiModules, module) then
    lume.push(singleton.imguiModules, module)
  end
end
console.help.memory = {
  section = 'Gameplay Debug',
  'Shows debug menu for inspecting memory usage'
}

function console.commands.imguidemo()
  if not IMGUI_EXISTS then
    console.print('You must have a debug build to use this command')
    return
  end
  local singleton = require 'engine.singletons'
  local module = require 'engine.imgui_modules.imgui_demo'
  if not lume.find(singleton.imguiModules, module) then
    lume.push(singleton.imguiModules, module)
  end
end
console.help.imguidemo = {
  section = 'Gameplay Debug',
  'Shows ImGui demo window'
}

function console.commands.debugdraw(flagsStr)
  local singleton = require 'engine.singletons'
  local gameControl = singleton.gameControl
  local EntityDebugDrawFlags = require('engine.enums.flags.entity_debug_draw_flags').enumMap
  flagsStr = ParseHelpers.trim(flagsStr)
  if flagsStr == '' then
    if gameControl.entityDebugDrawFlags == 0 then
      console.print('Enabling all debug draw flags')
      gameControl.entityDebugDrawFlags = bit.bor(EntityDebugDrawFlags.BumpBox, EntityDebugDrawFlags.RoomBox, EntityDebugDrawFlags.HitBox)
    else
      console.print('Disabling all debug draw flags')
      gameControl.entityDebugDrawFlags = 0
    end
  else
    local flags = lume.split(flagsStr, ',')
    for _, flag in ipairs(flags) do
      flag = flag:lower()
      if flag == 'bumpbox' then
        gameControl.entityDebugDrawFlags = bit.bxor(gameControl.entityDebugDrawFlags, EntityDebugDrawFlags.BumpBox)
      elseif flag == 'roombox' then
        gameControl.entityDebugDrawFlags = bit.bxor(gameControl.entityDebugDrawFlags, EntityDebugDrawFlags.RoomBox)
      elseif flag == 'hitbox' then
        gameControl.entityDebugDrawFlags = bit.bxor(gameControl.entityDebugDrawFlags, EntityDebugDrawFlags.HitBox)
      else
        console.print(('Unknown debug draw flag: %s'):format(flag))
      end
    end
  end
end
console.help.imguidemo = {
  section = 'Gameplay Debug',
  'Controls debug drawing. Optional flags are: "bumpbox", "roombox", "hitbox". Providing no flags will toggle all debug drawing.'
}