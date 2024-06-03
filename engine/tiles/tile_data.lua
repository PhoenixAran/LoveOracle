local Class = require 'lib.class'
local lume = require 'lib.lume'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local ph = require 'engine.utils.parse_helpers'
local Sprite = require 'engine.graphics.sprite'
local SpriteFrame = require 'engine.graphics.sprite_frame'
local TileSpriteRenderer = require 'engine.tiles.tile_sprite_renderer'
local dir8 = require 'engine.enums.direction8'

-- used to validate tile types
local TileTypeInverse = lume.invert(TileTypeFlags.enumMap)

local function makeTileSprite(tilesetTile)
  if tilesetTile:isAnimated() then
    local spriteFrames = { }
    for i = 1, lume.count(tilesetTile.animatedTextures) do
      local subtexture = tilesetTile.animatedTextures[i]
      local delay = math.floor(tilesetTile.durations[i] / 60) + 1
      lume.push(spriteFrames, SpriteFrame(Sprite(subtexture), delay))
    end
    return TileSpriteRenderer(spriteFrames, true)
  end
  return TileSpriteRenderer(Sprite(tilesetTile.subtexture), false)
end

local function parseTileType(tileType)
  if tileType == nil then
    return TileTypeFlags:get('normal').value
  end
  assert(TileTypeFlags:get(tileType) ~= nil, 'Invalid tiletype given: ' .. tostring(tileType))
  return TileTypeFlags:get(tileType).value
end

local function parseConveyorVector(conveyorVector)
  if conveyorVector == '' or conveyorVector == nil then
    return 0, 0
  end
  return dir8.getVector(dir8[conveyorVector])
end

local InstanceId = 0
local function newInstanceId()
  InstanceId = InstanceId + 1
  return InstanceId - 1
end

---@class TileData
---@field tilesetTileId integer
---@field sprite TileSpriteRenderer
---@field tileType integer
---@field hitX integer
---@field hitY integer
---@field hitW integer
---@field hitH integer
---@field minSwordLevel integer
---@field minBoomerangLevel integer
---@field conveyorVectorX number
---@field conveyorVectorY number
---@field conveyorSpeed number
---@field zRange ZRange
---@field instanceId integer
local TileData = Class {
  ---@param self TileData
  ---@param tilesetTile TiledTilesetTile
  init = function(self, tilesetTile)
    local properties = tilesetTile:getProperties()
    self.tilesetTileId = tilesetTile.id
    self.sprite = makeTileSprite(tilesetTile)
    self.tileType = parseTileType(properties.tileType)
    self.hitX, self.hitY, self.hitW, self.hitH = 0,0,0,0
    if properties.hasHitBox then
      self.hitX = properties.hitX or 0
      self.hitY = properties.hitY or 0
      self.hitW = properties.hitW or 0
      self.hitH = properties.hitH or 0
    end
    self.conveyorVectorX, self.conveyorVectorY = parseConveyorVector(properties.conveyorVector)
    self.conveyorSpeed = properties.conveyorSpeed or 0.0
    self.zRange = { min = 0, max = 1 }
    self.zRange.min = properties.zRangeMin or 0
    self.zRange.max = properties.zRangeMax or 1
    assert(self.zRange.min <= self.zRange.max, 'Invalid Z Range')
    -- used in Room.animatedTiles, Tileset.animatedTiles
    self.instanceId = newInstanceId()

    -- interact vars
    self.minSwordLevel = properties.minSwordLevel
    self.minBoomerangLevel  = properties.minBoomerangLevel
    
    --[[ TODO off the top of my head:
      1. Hit Damage
      2. Break Animation
      3. Break Sound
      4. Drop Table
      5. Pickable Entity Type
    ]]
  end
}

function TileData:getType()
  return 'tile_data'
end

function TileData:getCollisionZRange()
  return self.zRange.min, self.zRange.max
end

function TileData:getSprite()
  return self.sprite
end

return TileData