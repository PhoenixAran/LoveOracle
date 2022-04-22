local console = require 'lib.console'

-- timescale command
console.help.timescale = {
  section = "Gameplay",
  "Sets the timescale if a number is given.",
  "If not, it will return the current timescale value"
}
function console.commands.timescale(args)
  local tick  = require 'lib.tick'
  print(tonumber(args))
  if tonumber(args) then
    tick.timescale = tonumber(args)
  else
    console.print('Current timescale: ' .. tick.timescale)
  end
end

-- fullscreen command
console.help.fullscreen = {
  section = 'Graphics',
  'Toggles fullscreen'
}
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
