local cellSize = 64
print('Initializing physics world with cellsize ' .. cellSize)
local World =  require('lib.bump').newWorld(cellSize)
print 'Registering custom bump responses'
local path = ...
require (path .. '.bump_responses')(World)
return World
