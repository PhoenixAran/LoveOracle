local path = ...
return function(paletteBank)

  require(path .. '.player_palettes')(paletteBank)
end