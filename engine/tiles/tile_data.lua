local Class = require 'lib.class'
local lume = require 'lib.lume'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local ph = require 'engine.utils.parse_helpers'

local Sprite = require 'engine.graphics.sprite'
local SpriteFrame = require 'engine.graphics.sprite_frame'
local TileSpriteRenderer = require 'engine.tiles.tile_sprite_renderer'

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

local function parseRect(dimensions)
  local x, y, w, h = 0, 0, 0, 0
  if dimensions ~= nil then
    local args = ph.split(dimensions, ',')
    assert(lume.count(args) == 4)
    lume.each(args, ph.argIsNumber)
    x, y, w, h = tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
  end
  return x, y, w, h
end

local function parseCollisionBox(dimensions)
  if dimensions == nil then
    return 0, 0, 16, 16
  end
  return parseRect(dimensions)
end

local function parseHitBox(dimensions)
  if dimensions == nil then
    return 0, 0, 0, 0
  end
  return parseRect(dimensions)
end

local function parseZRange(zRange)
  if zRange == nil then
    return { min = 0, max = 1 }
  end
  zRange = ph.trim(zRange)
  if zRange == '' then
    return { min = 0, max = 1 }
  end
  local args = ph.split(zRange, ',')
  assert(lume.count(args) == 2)
  lume.each(args, ph.argIsNumber)
  return { min = tonumber(args[1]), max = tonumber(args[2]) }
end

local function parseConveyorVector(conveyorVector)
  if conveyorVector == nil then
    return 0, 0
  end
  if conveyorVector == '' then
    return 0, 0
  end
  local args = ph.split(conveyorVector, ',')
  assert(lume.count(args) == 2)
  lume.each(args, ph.argIsNumber)
  return tonumber(args[1]), tonumber(args[2])
end

local function parseConveyorSpeed(conveyorSpeed)
  if conveyorSpeed == nil then
    return 0
  end
  if conveyorSpeed == '' then
    return 0
  end
  ph.argIsNumber(conveyorSpeed)
  return tonumber(conveyorSpeed)
end

local InstanceId = 0

---@class TileData
---@field tilesetTileId integer
---@field sprite TileSpriteRenderer
---@field tileType integer
---@field x integer
---@field y integer
---@field w integer
---@field h integer
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
    self.x, self.y, self.w, self.h = parseCollisionBox(properties.collisionBox)
    self.hitX, self.hitY, self.hitW, self.hitH = parseHitBox(properties.hitBox)
    self.conveyorVectorX, self.conveyorVectorY = parseConveyorVector(properties.conveyorVector)
    self.conveyorSpeed = parseConveyorSpeed(properties.conveyorSpeed)
    self.zRange = parseZRange(properties.zRange)
    -- used in Room.animatedTiles, Tileset.animatedTiles
    InstanceId = InstanceId + 1
    self.instanceId = InstanceId
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