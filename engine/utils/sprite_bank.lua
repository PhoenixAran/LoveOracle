local fh = require 'engine.utils.file_helper'
local SpriteBank = { 
  sprites = { }
}

-- assumes flat directory because i'm lazy
function SpriteBank.initialize(directory)
  local files = love.filesystem.getDirectoryItems(directory)
  for _, file in ipairs(files) do
    local requirePath = fh.getFilePathWithoutExtension(directory .. '/' .. file):gsub('%/', '.')
    print(requirePath)
    local builder = require(requirePath)
    local key, sprite = builder.build()
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