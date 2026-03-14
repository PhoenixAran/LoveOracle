--- how the player visually holds the reward when collected
---@enum ItemRewardsHoldType
local ProjectileType = {
  -- the player does not hold the reward
  none = 0,
  -- the reward is held offset to the side in one hand
  oneHand = 1,
  -- the reward is held in the center in both hands
  twoHands = 2,
  -- the player spins the sword then raises it with one hand
  sword = 3
}