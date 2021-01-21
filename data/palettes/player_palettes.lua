local green = { 16, 168, 64 } -- the player spritesheet uses the default green tunic
local red = { 248, 8, 40 }
local blue = { 24, 128, 248 }
return function(paletteBank)
  local defenseTunicPalette = paletteBank.createPalette('player_defense_tunic')
  defenseTunicPalette:addColorPair(green, blue)
  paletteBank.register(defenseTunicPalette)
  
  local attackTunicPalette = paletteBank.createPalette('player_attack_tunic')
  attackTunicPalette:addColorPair(green, red)
  paletteBank.register(attackTunicPalette)
end