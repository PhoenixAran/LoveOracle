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
    self:signal('max_health_changed')
    self:signal('damage_taken')
    self:signal('health_reduced')
    self:signal('health_increased')
    self:signal('health_depleted')
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
---@param setCurrentHealthAlso boolean if the current health should also be set to max value
function Health:setMaxHealth(value, setCurrentHealthAlso)
  local oldMaxHealth = self.maxHealth
  self.maxHealth = value
  self:emit('max_health_changed', self.maxHealth, oldMaxHealth)

  if setCurrentHealthAlso then
    local oldHealth = self.health
    self.health = value
    if value > oldHealth then
      self:emit('health_increased', self.health, oldHealth)
    elseif value < oldHealth then
      self:emit('health_reduced', self.health, oldHealth)
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

  if value > oldHealth then
    self:emit('health_increased', self.health, oldHealth)
  elseif value < oldHealth then
    self:emit('health_reduced', self.health, oldHealth)
  end

  if self:isDepleted() then
    self:emit('health_depleted')
  end
end

---@param damage integer
function Health:takeDamage(damage)
  local oldHealth = self.health
  if 0 < damage then
    local actualDamage = damage - self.armor
    if 0 < actualDamage then
      self.health = self.health - actualDamage
      self:emit('health_reduced', self.health, oldHealth)
    end
    if self:isDepleted() then
      self:emit('health_depleted')
    end
  end
end

---@param amount integer
function Health:heal(amount)
  local oldHealth = self.health
  self.health = lume.clamp(self.health + amount, 0, self.maxHealth)
  self:emit('health_increased', self.health, oldHealth)
end

---@param value integer
function Health:setArmor(value)
  self.armor = value
end

function Health:getArmor()
  return self.armor
end

function Health:isDepleted()
  return self.health <= 0
end

return Health