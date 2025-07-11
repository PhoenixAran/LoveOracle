return {
  -- Maximum z-distance at which two bump boxes are still considered to be touching.
  -- If their z position (NOT Z Range) are separated by more than this, they are not colliding.
  BUMP_BOX_MAX_Z_DISTANCE = 10,

  TICK_RATE = 1 / 60,
  DEFAULT_GRAVITY = 7.5,

  -- math
  EPSILON = 0.001,

  -- HUD
  GRID_SIZE = 16,
  HUD_HEIGHT = 16,

  -- player
  PLAYER_JUMP_Z_VELOCITY = 2,
  PLAYER_JUMP_GRAVITY = 8,
  PLAYER_HOLE_DOOM_TIMER = 10,
  PLAYER_HOLE_PULL_MAGNITUDE = 15,
  PLAYER_DISTANCE_TRIGGER_HOLE_FALL = 1,

  -- generic enemy
  ENEMY_FALL_IN_HOLE_SLIP_SPEED = 40,
}