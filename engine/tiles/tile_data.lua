local Class = require 'lib.class'
local lume = require 'lib.lume'
local TileType = require 'engine.enums.tile_type'
local ph = require 'engine.utils.parse_helpers'

local SpriteFrame = require 'engine.graphics.sprite_frame'
local TileSpriteRenderer = require 'engine.tiles.tile_sprite_renderer'

-- used to validate tile types
local TileTypeInverse = lume.invert(TileType)

local function makeTileSprite(tilesetTile)
  if tilesetTile:isAnimated() then
    local spriteFrames = { }
    for i = 1, lume.count(tilesetTile.animatedTextures) do
      local subtexture = tilesetTile.animatedTextures[i]
      local delay = math.floor(tilesetTile.durations[i] / 60)
      lume.push(spriteFrames, SpriteFrame(subtexture, delay))
      return TileSpriteRenderer(spriteFrames, true)
    end
  end
  return TileSpriteRenderer(tilesetTile.subtexture, false)
end

local function parseTileType(tileType)
  assert(tileType == nil or TileTypeInverse[tileType], 'Invalid tiletype given: ' .. tostring(tileType))
  return tileType and tileType or TileType.Normal
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
    return 0, 1
  end
  zRange = ph.trim(zRange)
  if zRange == '' then
    return 0, 1
  end
  local args = ph.split(zRange, ',')
  assert(lume.count(args) == 2)
  lume.each(args, ph.argIsNumber)
  return tonumber(args[1]), tonumber(args[2])
end


local TileData = Class {
  init = function(self, tilesetTile)
    local properties = tilesetTile:getProperties()
    self.tilesetTileId = tilesetTile.id
    self.sprite = makeTileSprite(tilesetTile)
    self.tileType = parseTileType(properties.tileType)
    self.x, self.y, self.w, self.h = parseCollisionBox(properties.collisionBox)
    self.hitX, self.hitY, self.hitW, self.hitH = parseHitBox(properties.hitBox)
    self.zRange = parseZRange(properties.zRange)
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

return TileData