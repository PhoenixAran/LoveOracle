local Class = require 'lib.class'
local lume = require 'lib.lume'
local Physics = require 'engine.physics'
local Component = require 'engine.entities.component'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local TileTypes = TileTypeFlags.enumMap
local vector = require 'engine.math.vector'

local QUERY_RECT_LENGTH = 1.5

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
---@field onConveyor boolean
---@field inWater boolean
---@field inHole boolean
---@field onPlatform boolean
---@field conveyorVelocityX number
---@field conveyorVelocityY number
---@field queryFilter function
---@field bumpSorter function
---@field visitedTileIndices table<integer, boolean>
---@field tiles Tile[] Tiles that this ground observer is on top on
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
    self.onConveyor = false
    self.inWater = false
    self.inHole = false
    self.inPuddle = false

    local groundObserver = self
    local parentEntity = self.entity

    self.conveyorVelocityX = 0
    self.conveyorVelocityY = 0

    self.queryFilter = function(item)
      if (item.isTile and item:isTile()) or (item.getType and item:getType() == 'platform') then
        if item.isTopTile and not item:isTopTile() then
          return false
        end
        local entityZMin, entityZMax = parentEntity.zRange.min, parentEntity.zRange.max
        local itemZMin, itemZMax = item.zRange.min, item.zRange.max
        return entityZMax > itemZMin and itemZMax > entityZMin
      end
      return false
    end

    self.bumpSorter = function(a, b)
      local ex, ey = groundObserver.entity:getPosition()
      ex = ex + groundObserver.pointOffsetX
      ey = ey + groundObserver.pointOffsetY
      local distanceA = vector.dist(ex, ey, a.x, a.y)
      local distanceB = vector.dist(ex, ey, b.x, b.y)
      return distanceA <= distanceB
    end
    self.visitedTileIndices = { }
    self.tiles = { }
  end
}

function GroundObserver:getType()
  return 'ground_observer'
end

function GroundObserver:onTransformChanged()
  local ex, ey = self.entity:getPosition()
  self.x = ex + self.pointOffsetX
  self.y = ey + self.pointOffsetY
end

---@param x number
---@param y number
function GroundObserver:setOffset(x, y)
  self.pointOffsetX = x
  self.pointOffsetY = y
end

function GroundObserver:reset()
  self.inLava = false
  self.inGrass = false
  self.inPuddle = false
  self.onStairs = false
  self.onLadder = false
  self.onIce = false
  self.onConveyor = false
  self.inWater = false
  self.inHole = false
  self.inOcean = false
  lume.clear(self.visitedTileIndices)
  lume.clear(self.tiles)
end

function GroundObserver:update(dt)
  self:reset()

  if self.entity:isInAir() then
    return
  end

  local ex, ey = self.entity:getPosition()
  ex = ex + self.pointOffsetX
  ey = ey + self.pointOffsetY
  local items, len = Physics:queryRect(ex - QUERY_RECT_LENGTH / 2, ey - QUERY_RECT_LENGTH / 2, QUERY_RECT_LENGTH, QUERY_RECT_LENGTH, self.queryFilter)
  table.sort(items, self.bumpSorter)
  if 0 < len then
    for _, item in ipairs(items) do
      if item:isTile() then
        if not self.visitedTileIndices[item.index] then
          self.visitedTileIndices[item.index] = true
          lume.push(self.tiles, item)
          local tileType = item:getTileType()
          if tileType == TileTypes.Lava or tileType == TileTypes.Lavafall then
            self.inLava = true
          elseif tileType == TileTypes.Grass then
            self.inGrass = true
          elseif tileType == TileTypes.Puddle then
            self.inPuddle = true
          elseif tileType == TileTypes.Stairs then
            self.onStairs = true
          elseif tileType == TileTypes.Water or tileType == TileTypes.Ocean 
                 or tileType == TileTypes.Waterfall or tileType == TileTypes.Whirlpool then
            self.inWater = true
          elseif tileType == TileTypes.Ladder then
            self.onLadder = true
          elseif tileType == TileTypes.Ice then
            self.onIce = true
          elseif tileType == TileTypes.Conveyor then
            self.conveyorVelocityX, self.conveyorVelocityY = item:getConveyorVelocity()
            self.onConveyor = true
          elseif tileType == TileTypes.Hole then
            self.inHole = true
          end
        end
      else  -- its a platform
        self.onPlatform = true
      end
    end
  end

  Physics.freeTable(items)
end

function GroundObserver:getVisitedTiles()
  return self.tiles
end

function GroundObserver:debugDraw()
  local ex, ey = self.entity:getPosition()
  ex = ex + self.pointOffsetX
  ey = ey + self.pointOffsetY
  love.graphics.setColor(20 / 255, 219 / 255, 189 / 255, 150 / 255)
  love.graphics.points(ex, ey)
  love.graphics.setColor(1, 1, 1, 1)
end


return GroundObserver