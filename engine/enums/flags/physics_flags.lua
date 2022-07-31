local BitTagSet = require 'engine.utils.bit_tag_set'

local PhysicsFlags = BitTagSet('physics_flags')
PhysicsFlags:makeTags {
  'entity',
  'player',
  'enemy',
  'npc',
  'platform',
  'tile', 
  'room_edge',
  'push_block',
}
PhysicsFlags:makeEnumMap {
  Entity = 'entity',
  Player = 'player',
  Enemy = 'enemy',
  NPC = 'npc',
  Platform = 'platform',
  Tile = 'tile',
  RoomEdge = 'room_edge',
  PushBlock = 'push_block'
}
return PhysicsFlags