local path = ...
function moduleFunction(TilesetBank)
  require(path .. '.default')(TilesetBank)
  local tileset = TilesetBank.createTilesetTheme('theme_1')
  tileset:addTileset(TilesetBank.getTileset('prototype_a'))
  tileset:addTileset(TilesetBank.getTileset('prototype_c'))
  TilesetBank.registerTilesetTheme(tileset)
end

return makeModuleFunction(moduleFunction)