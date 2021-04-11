local Class = require 'lib.class'
local lume = require 'lib.lume'

local PlaceTileAction = Class {
  init = function(self, mapData, layerIndex, newTileId)
    self.mapData = mapData
    self.newTileId = newTileId
    self.layerIndex = layerIndex
    -- map index and old tile index pairs
    self.oldPairs = { }
  end
}

function PlaceTileAction:recordOldTile(mapIndexX, mapIndexY, oldTileId)
  self.oldPairs = lume.push({
    ['mapIndexX'] = mapIndexX,
    ['mapIndexY'] = mapIndexY,
    ['tileId'] = oldTileId
  })
end

function PlaceTileAction:getType()
  return 'place_tile_action'
end

--[[
  Common Action method implementation
]]
function PlaceTileAction:undo()
  for i, v in ipairs(self.oldPairs) do
    self.mapData:setTile(v.layerIndex, v.tileId, v.mapIndexX, v.mapIndexY)
  end
end

function PlaceTileAction:redo()
  for i, v in ipairs(self.oldPairs) do
    self.mapData.setTile(v.layerIndex, self.newTileId, v.mapIndexX, v.mapIndexY)
  end
end

function PlaceTileAction:isValid()
  return lume.count(self.oldPairs) > 0
end

return PlaceTileAction