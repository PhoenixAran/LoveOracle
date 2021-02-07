local path = ...
return function(spriteBank)
  require(path .. '.prototype_tile_sprites')(spriteBank)
  require(path .. '.player')(spriteBank)
  require(path .. '.entity_effects_sprite')(spriteBank)
  require(path .. '.tiles')(spriteBank)
end