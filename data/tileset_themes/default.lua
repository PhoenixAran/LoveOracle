function moduleFunction(TilesetBank)
  print('here')
  local tileset = TilesetBank.createTilesetTheme('default')
  tileset:addTileset(TilesetBank.getTileset('prototype_a'))
  tileset:addTileset(TilesetBank.getTileset('prototype_b'))
  TilesetBank.registerTilesetTheme(tileset)
end

return makeModuleFunction(moduleFunction)