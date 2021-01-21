local Palette = require 'engine.graphics.palette'
local lume = require 'lib.lume'

local PaletteBank = {
  palettes = { }
}

-- return a palette instance a data scripter can use
function PaletteBank.createPalette(name)
  return Palette(name)
end

function PaletteBank.register(palette)
  assert(PaletteBank.palettes[palette:getName()], 'PaletteBank already has palette with key ' .. palette:getName())
  PaletteBank.palettes[palette:getName()] = palette
end

function PaletteBank.getPalette(name)
  assert(PaletteBank.palettes[name], 'PaletteBank does not have palette with key ' .. name)
  return PaletteBank.palettesByName[name]
end

function PaletteBank.compilePalettes()
  lume.each(PaletteBank.palettes, 'compileShader')
end

function PaletteBank.initialize(path)
  path = path or 'data.palettes'
  require(path)(PaletteBank)
  PaletteBank.compilePalettes()
end

return PaletteBank