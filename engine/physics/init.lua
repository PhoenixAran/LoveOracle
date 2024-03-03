local cellSize = 32
love.log.trace('Initializing physics world with cellsize ' .. cellSize)
local World =  require('lib.bump').newWorld(cellSize)
love.log.trace('Registering custom bump responses')
local path = ...
require (path .. '.bump_responses')(World)
return World
