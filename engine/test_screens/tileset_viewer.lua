local Class = require 'lib.class'
local Slab = require 'lib.slab'
local TilesetBank = require 'engine.utils.tileset_bank'

local TilesetViewer = Class {
  init = function(self)
    self.tilesetName = ''
    self.tileset = nil
    self.startX = 12
    self.startY = 12
  end
}

function TilesetViewer:enter(prev, ...)
  Slab.Initialize()
end

function TilesetViewer:update(dt)
  Slab.Update(dt)
  Slab.BeginWindow('tileset-viewer', { Title = 'Tileset Viewer'})
  Slab.Text('Tileset')
  if Slab.Input('tileset-name', { Text = self.tilesetName, ReturnOnText = true}) then
    self.tilesetName = Slab.GetInputText()
  end
  Slab.SameLine()
  local searchButtonPressed = Slab.Button('Enter')
  if searchButtonPressed then
    if TilesetBank.tilesets[self.tilesetName] then
      self.tileset = TilesetBank.getTileset(self.tilesetName)
    end
  end
  Slab.EndWindow()
end

function TilesetViewer:draw()
  Slab.Draw()
  monocle:begin()
  if self.tileset then
    for x = 1, self.tileset.sizeX, 1 do
      for y = 1, self.tileset.sizeY, 1 do
        local tilesetData = self.tileset:getTile(x, y)
        local sprite = tilesetData:getSprite()
        local posX = ((x - 1) * 16) + self.startX
        local posY = ((y - 1) * 16) + self.startY
        sprite:draw(posX, posY)
      end
    end
  end
  monocle:finish()
end


return TilesetViewer