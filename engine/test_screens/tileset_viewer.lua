local Class = require 'lib.class'
local Slab = require 'lib.slab'

local TilesetViewer = Class {
  init = function(self)
    self.testEntity = nil
  end
}

function TilesetViewer:enter(prev, ...)
  Slab.Initialize()
end

function TilesetViewer:update(dt)
  Slab.Update(dt)
  Slab.BeginWindow('tileset-viewer', { Title = 'Tileset Viewer'})
  Slab.Text('Tileset')
  Slab.Input('tileset-name')
  Slab.SameLine()
  local searchButtonPressed = Slab.Button('Enter')
  if searchButtonPressed then
    
  end
  Slab.EndWindow()
end

function TilesetViewer:draw()
  love.graphics.clear(.4, .4, .4, 1.0)
  Slab.Draw()
end


return TilesetViewer