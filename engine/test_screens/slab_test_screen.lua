local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Slab = require 'lib.slab'

local Screen = Class { __includes = BaseScreen,
  init = function(self)
    
  end
}

function Screen:enter(previous, ...)
	Slab.Initialize(args)
end

function Screen:update(dt)
  Slab.Update(dt)
	Slab.BeginWindow('MyFirstWindow', {Title = "My First Window"})
	Slab.Text("Hello World")
	Slab.EndWindow()
end

function Screen:draw()
  monocle:begin()
  monocle:finish()
  Slab.Draw()
end

return Screen