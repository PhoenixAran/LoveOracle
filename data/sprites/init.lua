local path = ...
return function(spriteBank)
  require(path .. '.player')(spriteBank)
  require(path .. '.entity_effects_sprite')(spriteBank)
end