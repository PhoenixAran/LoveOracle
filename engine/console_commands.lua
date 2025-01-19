local console = require 'lib.console'
local lume = require 'lib.lume'
local IMGUI_EXISTS = pcall(require, 'imgui')
local function trim(s)

end

--- Console Command. Sets or Gets timescale
---@param args table
function console.commands.timescale(args)
  if tonumber(args) then
    love.timer.timeScale = tonumber(args)
  else
    console.print('Current timescale: ' .. tostring(love.timer.timeScale))
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
    if not lume.find(singleton.imguiModules) then
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