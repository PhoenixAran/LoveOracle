local Class = require 'lib.class'
local lume = require 'lib.lume'

local RemoveTileAction = Class {
  init = function(self, mapData, layerIndex)
    self.mapData = mapData
    self.layerIndex = layerIndex
    -- map index and old tile index pairs
    self.oldPairs = { }
  end
}

function RemoveTileAction:recordOldTile(mapIndexX, mapIndexY, oldTileId)
  self.oldPairs = lume.push({
    ['mapIndexX'] = mapIndexX,
    ['mapIndexY'] = mapIndexY,
    ['tileId'] = oldTileId
  })
end

function RemoveTileAction:getType()
  return 'place_tile_action'
end

--[[
  Common Action method implementation
]]
function RemoveTileAction:undo()
  for i, v in ipairs(self.oldPairs) do
    self.mapData:setTile(self.layerIndex, v.tileId, v.mapIndexX, v.mapIndexY)
  end
end

function RemoveTileAction:redo()
  for i, v in ipairs(self.oldPairs) do
    self.mapData:setTile(self.layerIndex, nil, v.mapIndexX, v.mapIndexY)
  end
end

function RemoveTileAction:isValid()
  return lume.count(self.oldPairs) > 0
end

return RemoveTileAction