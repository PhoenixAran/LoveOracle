local Class = require 'lib.class'

---@class PlayerSkills
---@field canSwimInWater boolean
---@field canSwimInLava boolean
local PlayerSkills = Class {
  init = function(self, args)
    args = args or { }
    self.canSwimInWater = args.canSwimInWater or false
    self.canSwimInLava = args.canSwimInLava or false
  end
}

function PlayerSkills:getType()
  return 'player_skills'
end

return PlayerSkills