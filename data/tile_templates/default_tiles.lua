return function(TileData)
  -- normal
  local normalTile = TileData()
  normalTile:setTileType('normal')
  TileData.registerTemplate('normal_tile', normalTile)
  
  local holeTile = TileData()
  holeTile:setTileType('hole')
  TileData.registerTemplate('hole')
  
  local iceTile = TileData()
  iceTile:setTileType('ice')
  TileData.registerTemplate('ice')
  
  local waterTile = TileData()
  waterTile:setTileType('water')
  TileData.registerTemplate('water')
end