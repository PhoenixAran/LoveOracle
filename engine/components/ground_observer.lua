local Class = require 'lib.class'
local lume = require 'lib.lume'
local Physics = require 'engine.physics'
local BitTag = require 'engine.utils.bit_tag'
local Component = require 'engine.entities.component'
local TileTypes = require 'engine.enums.tile_type'

local GroundObserver = Class { __includes = {Component},
  init = function(self, entity, args)
    if args == nil then
      args = { }
    end
    Component.init(self, entity, args)
    self.pointOffsetX = args.pointOffsetX or 0
    self.pointOffsetY = args.pointOffsetY or 0
    self.layerMask = BitTag.get('tile').value
    self.hits = { }
    self.inLava = false
    self.inGrass = false
    self.onStairs = false
    self.onLadder = false
    self.onIce = false
    self.inWater = false
    self.inHole = false
  end
}

function GroundObserver:getType()
  return 'ground_observer'
end

function GroundObserver:update(dt)
  self:reset()
  local ex, ey = self.entity:getPosition()
  local count = Physics.pointcast(ex + self.pointOffsetX, ey + self.pointOffsetY, self.hits,
                                self.layerMask, math.mininteger, math.maxinteger)
  if 0 < count then
    for _, tile in ipairs(self.hits) do
      local tileType = tile:getTileType()
      if tileType == TileTypes.Lava or tileType == TileTypes.LavaFall then
        self.inLava = true
      elseif tileType == TileTypes.Grass then
        self.inGrass = true
      elseif tileType == TileTypes.Stairs then
        self.onStairs = true
      elseif tileType == TileTypes.Ice then
        self.onIce = true
      elseif tileType == TileTypes.puddle or tileType == TileTypes.water 
          or tileType == TileTypes.DeepWater or tileType == TileTypes.Ocean
          or tileType == TileTypes.WaterFall or tileType == TileTypes.Whirlpool then
        self.inWater = true
      elseif tileType == TileTypes.Ladder then
        self.onLadder = true
      elseif tileType == TileTypes.Ice then
        self.onIce = true
      end
    end
  end
  lume.clear(self.hits)
end

function GroundObserver:reset()
  self.inLava = false
  self.inGrass = false
  self.onStairs = false
  self.onLadder = false
  self.onIce = false
  self.inWater = false
  self.inHole = false
end

return GroundObserver