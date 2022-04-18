local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local lume = require 'lib.lume'

local Health = Class { __includes = Component,
  init = function(self, entity, args)
    if args == nil then
      args = { }
    end
    Component.init(self, entity, args)
    self:signal('maxHealthChanged')
    self:signal('damageTaken')
    self:signal('healthChanged')
    self:signal('healthDepleted')
  
    if args.maxHealth == nil then args.maxHeath = 1 end
    if args.health == nil then args.health = args.maxHealth end
    if args.armor == nil then args.armor = 0 end

    self.maxHealth = args.maxHealth
    self.health = args.health
    self.armor = args.armor
  end
}

function Health:getType()
  return 'health'
end

function Health:getMaxHealth()
  return self.maxHealth
end

function Health:setMaxHealth(value)
  self.maxHealth = value
  self:emit('maxHealthChanged', self.maxHealth)
  if value < self.maxHealth then
    local oldHealth = self.health
    self.health = value
    self:emit('healthChanged', oldHealth, self.health)
  end
end

function Health:getHealth()
  return self.health
end

function Health:setHealth(value)
  local oldHealth = self.health
  self.health = value
  self:emit('healthChanged', oldHealth, self.health)
  if self:isDepleted() then
    self:emit('healthDepleted')
  end
end

function Health:takeDamage(damage)
  if 0 < damage then
    local actualDamage = damage - self.armor
    if 0 < actualDamage then
      self.health = self.health - actualDamage
      self:emit('healthChanged', self.health)
    end
    if self:isDepleted() then
      self:emit('healthDepleted')
    end
  end
end

function Health:heal(amount)
  self.health = lume.clamp(self.health + amount, 0, self.maxHealth)
  self:emit('healthChanged', self.health)
end

function Health:isDepleted()
  return self.health <= 0
end

return Health