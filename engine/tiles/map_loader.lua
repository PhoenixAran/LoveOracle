local TiledMapLoader = require 'engine.tiles.tiled.tiled_map_loader'

local tilesetCache = { }
local mapCache = { }

-- export type
local MapLoader = { }

function MapLoader.getTileset(name)
  local tiledTileset = TiledMapLoader.getTileset(name)
end

return TiledMapLoader