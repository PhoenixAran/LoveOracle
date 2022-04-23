local lume = require 'lib.lume'
local SpriteSheet = require 'engine.graphics.sprite_sheet'
local fh = require 'engine.utils.file_helper'
local ParseHelpers = require 'engine.utils.parse_helpers'

local AssetManager = { 
  imageCache = { },
  fontCache = { },
  soundCache = { },
  spriteSheetCache = { }
}

-- image
function AssetManager.loadImage(path)
  local key = fh.getFileNameWithoutExtension(path)
  assert(not AssetManager.imageCache[key], 'Image with key ' .. key .. ' already exists. Are you loading it twice?')
  local image = love.graphics.newImage(path)
  image:setFilter('nearest', 'nearest')
  image:setWrap('clampzero', 'clampzero')
  AssetManager.imageCache[key] = image
  return image
end

function AssetManager.getImage(key)
  assert(AssetManager.imageCache[key], 'Image with key ' .. key .. ' does not exist. Did you remember to load it?')
  return AssetManager.imageCache[key]
end

-- sound
function AssetManager.loadSoundSource(path, sourceType)
  local key = fh.getFileNameWithoutExtension(path)
  assert(not AssetManager.soundCache[key], 'Sound Source with key ' .. key .. ' already exists. Are you loading it twice?')
  local soundSource = love.audio.newSource(path, sourceType)
  AssetManager.soundCache[key] = soundSource
  return soundSource
end

function AssetManager.getSoundSource(key)
  assert(AssetManager.soundCache[key], 'Sound Source with key ' .. key .. ' does not exist. Did you remember to load it?')
  return AssetManager.soundCache[key]
end

-- font
function AssetManager.loadFont(path, key, fontSize)
  if fontSize == nil then
    fontSize = key
    key = nil
  end
  fontSize = fontSize or 16
  key = key or fh.getFileNameWithoutExtension(path)
  print(path, key, fontSize)
  assert(not AssetManager.fontCache[key], 'Font with key ' .. key .. ' already exists. Are you loading it twice?')
  local font = love.graphics.newFont(path, fontSize)
  font:setFilter('nearest', 'nearest')
  AssetManager.fontCache[key] = font
  return font
end

function AssetManager.getFont(key)
  assert(AssetManager.fontCache[key], 'Font with key ' .. key .. ' does not exist exists. Did you remember to load it?')
  return AssetManager.fontCache[key]
end

-- sprite sheets

-- load sprite sheet(s) via .spritesheet file
-- sprite sheet keys will be defined by whatever is defined in the sprite sheet line
function AssetManager.loadSpriteSheetFile(path)
  local lineCounter = 1
  for line in love.filesystem.lines(path) do
    if line then line = line:gsub('%$s+', '') end
    if not (line == nil or line == '' or line:sub(1, 1) == '#') then
      local args = ParseHelpers.split(line, ',')
      assert(#args == 4 or #args == 5 or #args == 6, 'Not enough arguments in ' .. path .. ' on line ' .. tostring(lineCounter) )
      
      local key = args[1]
      local imageKey = args[2]
      local width = args[3]
      local height = args[4]
      local margin = args[5]
      local spacing = args[6]
      assert(ParseHelpers.argIsString(key), 'Expected string in argument 1, but received :' .. tostring(key) .. ' in ' .. path .. ' on line ' .. tostring(lineCounter))
      assert(ParseHelpers.argIsString(imageKey), 'Expected string in argument 2, but received :' .. tostring(imageKey) .. ' in ' .. path .. ' on line ' .. tostring(lineCounter))
      assert(ParseHelpers.argIsNumber(width), 'Expected number in argument 3, but received :' .. tostring(width) .. ' in ' .. path .. ' on line ' .. tostring(lineCounter))
      assert(ParseHelpers.argIsNumber(height), 'Expected number in argument 4, but received :' .. tostring(height) .. ' in ' .. path .. ' on line ' .. tostring(lineCounter))
      assert(margin == nil or ParseHelpers.argIsNumber(margin), 'Expected nil or number in argument 5, but received :' .. tostring(margin) .. ' in ' .. path .. ' on line ' .. tostring(lineCounter))
      assert(spacing == nil or ParseHelpers.argIsNumber(spacing), 'Expected nil or number in argument 6, but received :' .. tostring(spacing) .. ' in ' .. path .. ' on line ' .. tostring(lineCounter))
      
      key = ParseHelpers.parseStringArg(key)
      imageKey = ParseHelpers.parseStringArg(imageKey)

      assert(not AssetManager.spriteSheetCache[key], 'Sprite Sheet with key ' .. key .. ' already exists.')
      AssetManager.spriteSheetCache[key] = SpriteSheet(AssetManager.getImage(imageKey), tonumber(args[3]), tonumber(args[4]), tonumber(args[5]), tonumber(args[6]))
    end
    lineCounter = lineCounter + 1
  end
end

function AssetManager.getSpriteSheet(key)
  assert(AssetManager.spriteSheetCache[key], 'Sprite Sheet with ' .. key .. ' does not exist')
  return AssetManager.spriteSheetCache[key]
end

function AssetManager.unload()
  lume.each(AssetManager.fontCache, 'release')
  AssetManager.fontCache = { }
  lume.each(AssetManager.soundCache, 'release')
  AssetManager.soundCache = { }
  lume.each(AssetManager.spriteSheetCache, 'release')
  AssetManager.spriteSheetCache = { }
  lume.each(AssetManager.imageCache, 'release')
  AssetManager.imageCache = { }
end

return AssetManager