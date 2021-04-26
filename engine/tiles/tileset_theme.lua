local Class = require 'lib.class'
local lume = require 'lib.lume'

--[[ 
   Table of tilesets that ALL themes must have.
   tilesets in each theme MUST be added in the SAME ORDER
   as declared in this table (which will be populated at the beginning of each game start)
   For example, if project defines tilesets as 'overworld, indoors, caves', then each theme
   must include the tilesets 'overworld, indoors, caves' in that EXACT order
]]
local REQUIRED_TILESETS = { }

local TilesetTheme = Class {
  init = function(self, name)
    self.name = name
    self.tilesets = { }
    self.tilesetsByName = { }
    self.tilesetIdOffsets = { }
    self.tiles = { }
  end
}

function TilesetTheme:getName()
  return self.name
end

function TilesetTheme:setName(name)
  self.name = name
end

function TilesetTheme:addTileset(tileset)
  local tilesetName = tileset:getAliasName()
  assert(tilesetName, 'Attempting to add tileset without name to tileset theme')
  assert(not self.tilesetsByName[tilesetName], 'Attempting add tileset ' .. tilesetName .. ' when it is already added to tileset theme')
  
  lume.push(self.tilesets, tileset)
  self.tilesetsByName[tilesetName] = tileset
  local offset = 0
  if self.tilesets[lume.count(self.tilesets) - 1] then
    offset = self.tilesets[lume.count(self.tilesets) - 1]:getSize()
  end
  self.tilesetIdOffsets[tilesetName] = offset
  for i, tileData in ipairs(tileset.tiles) do
    self.tiles[i + offset] = tileData
  end
end

function TilesetTheme:getTileset(index)
  if type(index) == 'string' then
    return self.tilesetsByName[index]
  else
    return self.tilesets[index]
  end
end

function TilesetTheme:getTile(gid)
  return self.tiles[gid]
end

function TilesetTheme:getTilesetForTileId(id)
  for i = 1, lume.count(self.tilesets) do
    local tileset = self.tilesets[i]
    local tilesetName = tileset:getAliasName()
    if self.tilesetIdOffsets[tilesetName] >= id then
      return tileset, self.tilesetIdOffsets[tilesetName]
    end
  end
  error('Could not find tileset theme for tile with id', id)
end

-- gets Gid for tile given a TileId, and the tileset it belongs too
function TilesetTheme:getTileGid(tileset, tileId)
  if type(tileset) == 'table' then
    tileset = tileset:getAliasName()
  end
  assert(self.tilesetIdOffsets[tileset], 'Cannot find offset for tileset ' .. tileset .. 'for tileset theme ' .. self:getName())
  return self.tilesetIdOffsets[tileset] + tileId
end

function TilesetTheme:getType()
  return 'tileset_theme'
end

function TilesetTheme.setRequiredTilesets(requiredTilesets)
  REQUIRED_TILESETS = lume.clone(requiredTilesets)
end

function TilesetTheme.validateTheme(tilesetTheme)
  assert(lume.count(tilesetTheme.tilesets) == lume.count(REQUIRED_TILESETS), 'Tileset Theme "' .. tilesetTheme:getName() .. '" does not have enough tilesets.')
  for k, tileset in ipairs(tilesetTheme.tilesets) do
    local name = tileset:getAliasName()
    local expectedName =  REQUIRED_TILESETS[k]
    if name ~= expectedName then
      error('Expected tileset "' .. expectedName .. '", but got tileset "' ..  name .. '" in tileset theme ' .. tilesetTheme:getAliasName())
    end
  end
end

function TilesetTheme.getRequiredTilesets()
  return lume.clone(REQUIRED_TILESETS)
end

return TilesetTheme