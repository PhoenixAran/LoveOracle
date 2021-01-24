local Class = require 'lib.class'
local lume = require 'lib.lume'
local inspect = require 'lib.inspect'
local Slab = require 'lib.slab'
local AssetManager = require 'engine.utils.asset_manager'
local BaseScreen = require 'engine.screens.base_screen'

local MapEditor = Class { __include = BaseScreen,
  init = function(self)
    
    
  end
}

function MapEditor:enter(prev, ...)
  
end

function MapEditor:update(dt)
  
end

function MapEditor:draw()
  love.graphics.clear(.4, .4, .4, 1.0)
  
end

return MapEditor