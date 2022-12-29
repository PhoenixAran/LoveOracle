local Class = require 'lib.class'
local lume = require 'lib.lume'
local Physics = require 'engine.physics'
local Component = require 'engine.entities.component'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local TileTypes = TileTypeFlags.enumMap

---@class GroundObserver : Component
---@field pointOffsetX number
---@field pointOffsetY number
---@field layerMask number
---@field hits Tile[]
---@field inLava boolean
---@field inPuddle boolean
---@field inGrass boolean
---@field onStairs boolean
---@field onLadder boolean
---@field onIce boolean
---@field inWater boolean
---@field inHole boolean
---@field onPlatform boolean
---@field queryPointFilter function
---@field visitedTileIndices table<integer, boolean>
local GroundObserver = Class { __includes = {Component},
  init = function(self, entity, args)
    if args == nil then
      args = { }
    end
    Component.init(self, entity, args)
    self.pointOffsetX = args.pointOffsetX or 0
    self.pointOffsetY = args.pointOffsetY or 0
    self.layerMask = PhysicsFlags:get('tile').value
    self.inLava = false
    self.inGrass = false
    self.onStairs = false
    self.onLadder = false
    self.onIce = false
    self.inWater = false
    self.inHole = false
    self.inPuddle = false

    local parentEntity = self.entity
    self.queryPointFilter = function(item)
      if (item.isTile and item:isTile()) or (item.getType and item:getType() == 'platform') then
        local entityZMin, entityZMax = parentEntity.zRange.min, parentEntity.zRange.max
        local itemZMin, itemZMax = item.zRange.min, item.zRange.max
        return entityZMax > itemZMin and itemZMax > entityZMin
      end
      return false
    end
    self.visitedTileIndices = { }
  end
}

local function zRangeMaxSort(a, b)
  local aMax = a.zRange.max
  local bMax = b.zRange.max
  return aMax > bMax
end

function GroundObserver:getType()
  return 'ground_observer'
end

function GroundObserver:update(dt)
  self:reset()
  local ex, ey = self.entity:getPosition()
  local items, len = Physics:queryPoint(ex + self.pointOffsetX, ey + self.pointOffsetY, self.queryPointFilter)
  lume.sort(items, zRangeMaxSort)
  if 0 < len then
    for _, item in ipairs(items) do
      if item:isTile() then
        if not self.visitedTileIndices[item.index] then
          self.visitedTileIndices[item.index] = true
          local tileType = item:getTileType()
          if tileType == TileTypes.Lava or tileType == TileTypes.Lavafall then
            self.inLava = true
          elseif tileType == TileTypes.Grass then
            self.inGrass = true
          elseif tileType == TileTypes.Puddle then
            self.inPuddle = true
          elseif tileType == TileTypes.Stairs then
            self.onStairs = true
          elseif tileType == TileTypes.Water or tileType == TileTypes.DeepWater or tileType == TileTypes.Ocean
              or tileType == TileTypes.Waterfall or tileType == TileTypes.Whirlpool then
            self.inWater = true
          elseif tileType == TileTypes.Ladder then
            self.onLadder = true
          elseif tileType == TileTypes.Ice then
            self.onIce = true
          end
        end
      else  -- its a platform
        self.onPlatform = true
      end
    end
  end
  Physics.freeTable(items)
end

function GroundObserver:reset()
  self.inLava = false
  self.inGrass = false
  self.inPuddle = false
  self.onStairs = false
  self.onLadder = false
  self.onIce = false
  self.inWater = false
  self.inHole = false
  lume.clear(self.visitedTileIndices)
end

return GroundObserver