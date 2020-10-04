local SpriteSheet = require 'engine.graphics.sprite_sheet'

local AssetManager = { 
  directory = nil,
  cache = { }
}

local function getCombinedPath(path)
  return AssetManager.directory .. path
end

local function split(str, inSplitPattern)
  local outResults = { }
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( str, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( str, theStart ) )
  return outResults
end

function AssetManager.setDirectory(directory)
  AssetManager.directory = directory
end

function AssetManager.getImage(path)
  if AssetManager.cache[path] then
    return AssetManager.cache[path]
  end
  local image = love.graphics.newImage(getCombinedPath(path))
  image:setFilter('nearest', 'nearest')
  AssetManager.cache[path] = image
  return image
end

function AssetManager.getSoundSource(path, sourceType)
  if AssetManager.cache[path] then
    return AssetManager.cache[path]
  end
  local soundSource = love.audio.newSource(getCombinedPath(path), sourceType)
  AssetManager.cache[path] = soundSource
  return image
end

function AssetManager.getFont(path, fontSize)
  fontSize = fontSize or 16
  if AssetManager.cache[path] then
    return AssetManager.cache[path]
  end
  local font = love.graphics.newFont(getCombinedPath(path), fontSize)
  font:setFilter('nearest', 'nearest')
  AssetManager.cache[path] = font
  return font
end

-- should probably put this in the sprite bank class instead
function AssetManager.loadSpriteSheetFile(path)
  path = getCombinedPath(path)
  for line in love.filesystem.lines(path) do
    if line then line = line:gsub('%$s+', '') end
    if not (line == nil or line == '' or line:sub(1, 1) == '#') then
      local args = split(line, ',')
      local image = AssetManager.getImage(args[2])
      AssetManager.cache[args[1]] = SpriteSheet(image, tonumber(args[3]), tonumber(args[4]), tonumber(args[5]), tonumber(args[6]))
    end
  end
end

function AssetManager.getSpriteSheet(key)
  return AssetManager.cache[key]
end

return AssetManager