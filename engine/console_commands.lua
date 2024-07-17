local console = require 'lib.console'

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