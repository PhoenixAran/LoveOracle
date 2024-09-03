local BitTagSet = require 'engine.utils.bit_tag_set'

local PhysicsFlags = BitTagSet('physics_flags')
PhysicsFlags:makeTags {
  'entity',
  'player',
  'enemy',
  'npc',
  'moving_platform',
  'tile', 
  'room_edge',
  'push_block',
  'ledge_jump'
}
PhysicsFlags:makeEnumMap {
  Entity = 'entity',
  Player = 'player',
  Enemy = 'enemy',
  NPC = 'npc',
  MovingPlatform = 'moving_platform',
  Tile = 'tile',
  RoomEdge = 'room_edge',
  PushBlock = 'push_block',
  LedgeJump = 'ledge_jump'
}

return PhysicsFlags