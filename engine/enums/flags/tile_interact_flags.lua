local BitTagSet = require 'engine.utils.bit_tag_set'

local TileInteractFlags = BitTagSet('TileInteractFlags')

TileInteractFlags:makeTags {
  'bombable',
  'boomerangable',
  'burnable',
  'coverable',
  'cuttable',
  'clingOnStab',
  'pickupable'
}

TileInteractFlags:makeEnumMap {
  Bombable = 'bombable',
  Boomerangle = 'boomerangable',
  Burnable = 'burnable',
  Coverable = 'coverable',
  Cuttable = 'cuttable',
  ClingOnStab = 'clingOnStab',
  Pickupable = 'pickupable'
}

return TileInteractFlags