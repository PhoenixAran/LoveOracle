local Class = require 'lib.class'
local lume = require 'lib.lume'

--[[ 
   Table of tilesets that ALL themes must have.
   tilesets in each theme MUST be added in the SAME ORDER
   as declared in this table (which will be populated at the beginning of each game start)
   For example, if project defines tilesets as 'overworld, indoors, caves', then each theme
   must include the tilesets 'overworld, indoors, caves' in that EXACT order
]]
local DECLARED_TILESETS = { }

local TilesetTheme = Class {
  init = function(self, name)
    self.name = name
    self.tilesets = { }
    self.tilesetIdOffsets = { }
  end
}

function TilesetTheme:getName()
  return self.name
end

function TilesetTheme:setName(name)
  self.name = name
end

function TilesetTheme:addTileset(tileset)
  local tilesetName = tileset:getName()
  assert(tilestName, 'Attempting to add tileset without name to tileset theme')
  assert(not self.tilesets[tilesetName], 'Attempting add tileset ' .. tilesetName .. ' when it is already added to tileset theme')
  
  self.tilesets[tilesetName] = tileset
  self.tilesetIdOffsets[tilesetName] = tileset:getSize()
end

function TilesetTheme:getTile(id)
  -- find theme with tile id offset less than id
  local idModifier = 0
  for i = 1, lume.count(self.tilesets) do
    local tileset = self.tilesets[i]
    local tilesetName = tileset:getName()
    local offset = self.tilesetIdOffsets[tilesetName]
    if offset >= id then
      return tileset:getTile(id - offset)
    end
  end
end

function TilesetTheme:getType()
  return 'tileset_theme'
end

function TilesetTheme.setDeclaredTilesets(declaredTilesets)
  DECLARED_TILESETS = lume.clone(declaredTilesets)
end

function TilesetTheme.validateTheme(tilesetTheme)
  for k, tileset in ipairs(self.tilesets) do
    local name = tileset:getName()
    local expectedName = DECLARED_TILESETS[k]
    if name ~= expectedName then
      error('Expected tileset "' .. expectedName .. '", but got tileset "' ..  name .. '" in tileset theme ' .. self:getName())
    end
  end
end

function TilesetTheme:validateTheme()
  return TilesetTheme.validateTheme(self)
end

return TilesetTheme