function moduleFunction(TilesetBank)
  local tileset = TilesetBank.createTilesetTheme('theme_1')
  tileset:addTileset(TilesetBank.getTileset('prototype_a'))
  tileset:addTileset(TilesetBank.getTileset('prototype_b'))
  TilesetBank.registerTilesetTheme(tileset)
end

return makeModuleFunction(moduleFunction)