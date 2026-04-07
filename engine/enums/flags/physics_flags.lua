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
  'ledge_jump',

  'hitbox_enemy',
  'hitbox_player'
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
  LedgeJump = 'ledge_jump',

  -- hitboxes owned by enemies, enemy items, and enemy projectiles
  HitboxEnemy = 'hitbox_enemy', 
  -- hitboxes owned by player, player items, and player projectiles
  HitboxPlayer = 'hitbox_player'
}

return PhysicsFlags