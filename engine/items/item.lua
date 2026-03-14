local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local Input = require('engine.singletons').input

---@class Item : Entity
---@field id string
---@field name string[] names indexed by level
---@field description string[] descriptions indexed by level
---@field maxLevel integer max level of this item
---@field message string[] message shown when item is obtained, indexed by level
---@field price integer[] price of item in shop, indexed by level
---@field player Player
---@field level integer
---@field useButtons string[]
---@field drawBelow nil|function
---@field drawAbove nil|function
---@field itemRewardHoldsType ItemRewardsHoldType how the player visually holds the reward when collected
local Item = Class { __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)
    self.id = args.id or nil
    self.names = { }
    self.name = nil
    self.level = 0
    self.useButtons = { }
    self.prices = { }
    self.player = nil
    self.itemRewardsHoldType = args.itemRewardsHoldType or 0

  end
}

function Item:getType()
  return 'item'
end

function Item:isEquippable()
  return false
end

function Item:getName()
  return self.name
end

function Item:onAwake()

end


function Item:getPlayer()
  return self.player
end

function Item:setPlayer(player)
  self.player = player
  self:setPosition(player:getPosition())
end

function Item:getLevel()
  return self.level
end



function Item:getUseButton()
  return self.useButtons
end

function Item:isButtonDown()
  for _, button in ipairs(self.useButtons) do
    if Input:down(button) then
      return true
    end
  end
  return false
end

function Item:isButtonPressed()
  for _, button in ipairs(self.useButtons) do
    if Input:pressed(button) then
      return true
    end
  end
  return false
end

-- feel free to override this
function Item:isUsable()
  local player = self.player
  if not player:getStateParameters().canUseWeapons then
    return false
  elseif player:isInAir() and not self.useParameters.usableWhileJumping then
    return false
  elseif self.player:getWeaponState() ~= nil and
          self.player:getWeaponState():getType() == 'sword' and -- TODO: add sword state checks as time goes on
          not self.useParameters.usableWithSword then
    return false
  end
  -- TODO check if player is in hole
  return true
end


---@param sender Hitbox
function Item:overridesInteraction(sender)
end

-- called when assigned buttons are down
function Item:onButtonDown()
  
end

-- called when items are pressed this frame
function Item:onButtonPressed()
  return false
end

function Item:update()
end

function Item:draw()
end

function Item:interrupt()
  
end

function Item:drawUnder()

end

function Item:drawOver()

end

return Item