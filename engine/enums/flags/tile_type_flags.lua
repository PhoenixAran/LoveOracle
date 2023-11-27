local BitTagSet = require 'engine.utils.bit_tag_set'

local TileTypeFlags = BitTagSet('TileTypes')
TileTypeFlags:makeTags {
  'normal',
  'wall',
  'stairs',
  'ladder',
  'ice',
  'puddle',
  'grass',
  'hole',
  'water',
  'deep_water',
  'ocean',
  'waterfall',
  'lava',
  'lavafall',
  'whirlpool',
  'conveyor'
}

TileTypeFlags:makeEnumMap {
  Normal = 'normal',
  Wall = 'wall',
  Stairs = 'stairs',
  Ladder = 'ladder',
  Puddle = 'puddle',
  Grass = 'grass',
  Hole = 'hole',
  Water = 'water',
  DeepWater = 'deep_water',
  Ocean = 'ocean',
  Waterfall = 'waterfall',
  Lava = 'lava',
  Lavafall = 'lavafall',
  Whirlpool = 'whirlpool',
  Conveyor = 'conveyor'
}
return TileTypeFlags