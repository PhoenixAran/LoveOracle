local path = ...
return function(spriteBank)
  require(path .. '.player_sprite')(spriteBank)
  require(path .. '.player_sword_sprite')(spriteBank)
end