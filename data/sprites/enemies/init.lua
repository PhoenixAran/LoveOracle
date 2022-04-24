local path = ...
return function(spriteBank)
  require(path .. 'stalfos_sprite')(spriteBank)
end