local Class = require 'lib.class'
local lume = require 'lib.lume'

--[[ 
  "Virtual" sprite sheet (best way i can describe it)
  Each index can hold different sprits of all sizes
  This is mainly used to organize the different kinds of sprites
  (composite sprites, color sprites) into a spritesheet
  so they can be easily accessed when data scripting the tilesets
  
  Spritesets also allow you to retrieve sprites by name, which makes scripting
  stuff like tilesets much more readable
]]
---@class Spriteset
---@field name string
---@field size integer
---@field sizeX integer
---@field sizeY integer
---@field Sprites Sprite[]|ColorSprite[]|PrototypeSprite[]|CompositeSprite[]
---@field SpriteHash table<number, Sprite>
---@field viewerSize number
local Spriteset = Class {
  -- viewersize is used in SpriteSet viewer
  init = function(self, name, sizeX, sizeY, viewerSize)
    if viewerSize == nil then
      viewerSize = 16
    end
    self.name = name
    self.size = sizeX * sizeY
    self.sizeX = sizeX
    self.sizeY = sizeY
    self.sprites = { }
    self.spriteHash = { }
    self.viewerSize = viewerSize
  end
}

function Spriteset:getType()
  return 'spriteset'
end

function Spriteset:getName()
  return self.name
end

---sets sprite with key
---@param name string
---@param sprite Sprite
---@param x integer
---@param y integer
function Spriteset:setSprite(name, sprite, x, y)
  if y == nil then
    assert(x <= lume.count(self.sprites)) 
    self.sprites[x] = sprite
  end
  assert(1 <= x and x <= self.sizeX)
  assert(1 <= y and y <= self.sizeY)
  self.sprites[(y - 1) * self.sizeX + x] = sprite
end

---gets sprite wity ke6y
---@param x number | string
---@param y number?
---@return Sprite
function Spriteset:getSprite(x, y)
  if y == nil then
    if type(x) == 'string' then
      assert(self.spriteHash[x], 'Spriteset ' .. self:getName() .. ' does not have sprite with name ' .. x)
      return self.spriteHash[x]
    else
      assert(x <= lume.count(self.sprites)) 
      return self.sprites[x]
    end
  end
  assert(1 <= x and x <= self.sizeX)
  assert(1 <= y and y <= self.sizeY)
  return self.sprites[(y - 1) * self.sizeX + x]
end


function Spriteset:release()
  for _, sprite in ipairs(self.sprites) do
    sprite:release()
  end
  self.spriteHash = { }
  self.sprites = { }
end

return Spriteset