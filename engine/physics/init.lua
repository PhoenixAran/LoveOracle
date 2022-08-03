print 'Initializing physics world with cellsize 32'
local World =  require('lib.bump').newWorld(32)
print 'Registering custom bump responses'
local path = ...
require (path .. '.bump_responses')(World)
return World
