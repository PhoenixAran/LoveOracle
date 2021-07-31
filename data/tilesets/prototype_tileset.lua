-- prototype_tileset.lua
function moduleFunction(tilesetBank)
  -- TILESET PROTOTYPE1
  local tileset = tilesetBank.createTileset('prototype_a', 2, 2)
  -- ground
  local tileData = tileset:createTileData('normal')
  tileData:setName('prototype_ground')
  tileData:setSprite('prototype_ground_tile')
  tileset:setTile(tileData, 1, 1)
  
  -- hole
  tileData = tileset:createTileData('hole')
  tileData:setName('prototype_hole')
  tileData:setSprite('prototype_hole_tile')
  tileset:setTile(tileData, 1, 2)
  
  -- ice
  tileData = tileset:createTileData('ice')
  tileData:setName('prototype_ice')
  tileData:setSprite('prototype_ice_tile')
  tileset:setTile(tileData, 2, 1)
  
  -- water
  tileData = tileset:createTileData('water')
  tileData:setName('prototype_water')
  tileData:setSprite('prototype_water_tile')
  tileset:setTile(tileData, 2, 2)
  
  tilesetBank.registerTileset(tileset)
  
  -- TILESET PROTOTYPE2
  tileset = tilesetBank.createTileset('prototype_b', 2, 2)
  -- water
  tileData = tileset:createTileData('water')
  tileData:setName('prototype_water')
  tileData:setSprite('prototype_water_tile')
  tileset:setTile(tileData, 1, 1)
  
  -- ice
  tileData = tileset:createTileData('ice')
  tileData:setName('prototype_ice')
  tileData:setSprite('prototype_ice_tile')
  tileset:setTile(tileData, 1, 2)
  
  -- hole
  tileData = tileset:createTileData('hole')
  tileData:setName('prototype_hole')
  tileData:setSprite('prototype_hole_tile')
  tileset:setTile(tileData, 2, 1)

  -- ground
  tileData = tileset:createTileData('normal')
  tileData:setName('prototype_ground')
  tileData:setSprite('prototype_ground_tile')
  tileset:setTile(tileData, 2, 2)
  tilesetBank.registerTileset(tileset)

  -- TILESET PROTOTYPE3 (ALIAS PROTOTYPE 2)
  tileset = tilesetBank.createTileset('prototype_c', 2, 2)
  tileset:setAliasName('prototype_b')
  -- water
  tileData = tileset:createTileData('water')
  tileData:setName('prototype_water')
  tileData:setSprite('prototype_water_tile')
  tileset:setTile(tileData, 1, 1)
  
  -- ice
  tileData = tileset:createTileData('ice')
  tileData:setName('prototype_ice')
  tileData:setSprite('prototype_ice_tile')
  tileset:setTile(tileData, 1, 2)
  
  -- hole
  tileData = tileset:createTileData('hole')
  tileData:setName('prototype_hole')
  tileData:setSprite('prototype_hole_tile')
  tileset:setTile(tileData, 2, 1)

  -- ground
  tileData = tileset:createTileData('normal')
  tileData:setName('prototype_ground')
  tileData:setSprite('prototype_ice_tile')
  tileset:setTile(tileData, 2, 2)
  tilesetBank.registerTileset(tileset)
end

return makeModuleFunction(moduleFunction)
