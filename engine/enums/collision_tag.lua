-- used in Entity hitboxes

local CollisionTag = {
  none = 'none',

  -- entities
  player = 'player',
  enemy = 'enemy',
  npc = 'npc',

  -- weapons
  sword = 'sword',
  arrow = 'arrow',
  thrownProjectile = 'thrown_projectile',
  shield = 'shield',
  boomerang = 'boomerang',

  -- other
}

return CollisionTag