function moduleFunction(TileData)
  -- normal
  local normalTile = TileData()
  normalTile:setTileType('normal')
  TileData.registerTemplate('normal_tile', normalTile)
  
  local holeTile = TileData()
  holeTile:setTileType('hole')
  TileData.registerTemplate('hole', holeTile)
  
  local iceTile = TileData()
  iceTile:setTileType('ice')
  TileData.registerTemplate('ice', iceTile)
  
  local waterTile = TileData()
  waterTile:setTileType('water')
  TileData.registerTemplate('water', waterTile)
end

return makeModuleFunction(moduleFunction)