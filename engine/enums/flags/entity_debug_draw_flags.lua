local BitTagSet = require 'engine.utils.bit_tag_set'

local EntityDebugDrawFlags = BitTagSet('debug_draw_flags')
EntityDebugDrawFlags:makeTags {
  'bumpBox',
  'roomBox',
  'hitBox',
  'items'
}

EntityDebugDrawFlags:makeEnumMap {
  BumpBox = 'bumpBox',
  RoomBox = 'roomBox',
  HitBox = 'hitBox'
}

return EntityDebugDrawFlags