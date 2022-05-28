local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local lume = require 'lib.lume'

---@class Health : Component
---@field maxHealth integer
---@field health integer
---@field armor integer
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
    args.maxHealth = nil or 1
    args.health = args.health or args.maxHealth
    args.armor = args.armor or 0
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

---sets max health
---@param value integer
---@param setCurrentHealthAlso integer if the current health should also be set to max value
function Health:setMaxHealth(value, setCurrentHealthAlso)
  self.maxHealth = value
  self:emit('maxHealthChanged', self.maxHealth)
  if value < self.maxHealth then
    local oldHealth = self.health
    if setCurrentHealthAlso then
      self.health = value
      self:emit('healthChanged', self.health, oldHealth)
    end
  end
end

function Health:getHealth()
  return self.health
end

---@param value integer
function Health:setHealth(value)
  local oldHealth = self.health
  self.health = value
  self:emit('healthChanged', self.health, oldHealth)
  if self:isDepleted() then
    self:emit('healthDepleted')
  end
end

---@param damage integer
function Health:takeDamage(damage)
  local oldHealth = self.health
  if 0 < damage then
    local actualDamage = damage - self.armor
    if 0 < actualDamage then
      self.health = self.health - actualDamage
      self:emit('healthChanged', self.health, oldHealth)
    end
    if self:isDepleted() then
      self:emit('healthDepleted')
    end
  end
end

---@param amount integer
function Health:heal(amount)
  self.health = lume.clamp(self.health + amount, 0, self.maxHealth)
  self:emit('healthChanged', self.health)
end

function Health:isDepleted()
  return self.health <= 0
end

return Health