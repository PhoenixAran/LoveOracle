local Class = require 'lib.class'

---@class PlayerSkills
---@field canSwimInWater boolean
---@field canSwimInLava boolean
---@field jumpSkill integer
local PlayerSkills = Class {
  init = function(self, args)
    args = args or { }
    --self.canSwimInWater = args.canSwimInWater or true
    self.canSwimInWater = true
    self.canSwimInLava = args.canSwimInLava or false
    self.jumpSkill = 1
  end
}

function PlayerSkills:getType()
  return 'player_skills'
end

return PlayerSkills