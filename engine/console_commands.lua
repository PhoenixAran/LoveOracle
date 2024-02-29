local console = require 'lib.console'


--- Console Command. Sets or Gets timescale
---@param args table
function console.commands.timescale(args)
  local tick  = require 'lib.tick'
  if tonumber(args) then
    tick.timescale = tonumber(args)
  else
    console.print('Current timescale: ' .. tick.timescale)
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
  love.log.trace('Log dumped via console command')
  love.log.dump()
end
console.help.dumplog = {
  section = 'Debug',
  'Dumps log to file'
}