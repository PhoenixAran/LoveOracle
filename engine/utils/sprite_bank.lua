local SpriteBank = { 
  sprites = { }
}

-- assumes flat directory because i'm lazy
function SpriteBank.initialize(directory)
  directory = assetManager.directory .. '/' .. directory
  local files = love.filesystem.getDirectoryItems(directory)
  print(#files)
  for _, file in ipairs(files) do
    local builder = require(directory .. '.' .. file)
    local key, sprite = builder.construct()
    builder[key] = sprite
  end
end

function SpriteBank.registerSprite(key, sprite)
  SpriteBank[key] = sprite
end

function SpriteBank.create(key)
  sprites[key]:clone()
end

return SpriteBank