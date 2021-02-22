local Class = require 'lib.class'
local lume = require 'lib.lume'
local RoomData = require 'engine.tiles.room_data'

local NIL_TABLE = { }

local function makeTilesTable(layers)
  local table = { }
  for i = 1, layers do
    table[i] = { }
  end
  return table
end

local MapData = Class {
  init = function(self, data)
    if not data then 
      data = NIL_TABLE
    end
    self.name = data.name or nil
    self.sizeX = data.sizeX or 16
    self.sizeY = data.sizeY or 16
    self.size = self.sizeX * self.sizeY
    self.layers = data.layers or 3
    self.tiles = data.tiles or makeTilesTable(data.layers)
    
    data.rooms = data.rooms or { }
    local rooms = { }
    lume.each(data.rooms, function(roomData)
      rooms.push(RoomData(roomData))
    end)
    self.rooms = rooms
  end
}

function MapData:getType()
  return 'map_data'
end

function MapData:getName()
  return self.name
end

function MapData:setName(name)
  self.name = name
end

function MapData:getLayers()
  return self.layers
end

function MapData:setLayers(layers)
  self.layers = layers
end

function MapData:getSize()
  return self.size
end

function MapData:getSizeX()
  return self.sizeX
end

function MapData:getSizeY()
  return self.sizeY
end

function MapData:getSizeXY()
  return self.sizeX, self.sizeY
end

function MapData:resize(x, y)
  --TODO: figure out how to handle existing tile placement when resizing maps
end

function MapData:setTile(tileData, x, y)
  if y == nil then
    assert(x <= self.sizeX, 'x is out of bounds')
    self.tiles[x] = tileData
  else
    local index = (x - 1) * self.sizeY + y
    assert(index <= self.size, '(' .. tostring(x) .. ', ' + tostring(y) .. ' is out of bounds')
    self.tiles[(x - 1) * self.sizeY + y] = tileData 
  end
end

function MapData:getTile(x, y)
  if y == nil then
    assert(x <= self.size, 'x is out of bounds')
    return self.tiles[x]
  end
  local index = (x - 1) * self.sizeY + y
  assert(index <= self.size, '( ' .. tostring(x) .. ', ' .. tostring(y) .. ') is out of bounds')
  return self.tiles[index]
end

function MapData:getTiles()
  return self.tiles
end

function Tileset:count()
  return lume.count(self.tiles)
end

function MapData:getSerializableTable()
  return {
    name = self:getName(),
    layers = self:getLayers(),
    tiles = self:getTiles(),
    sizeX = self:getSizeX(),
    sizeY = self:getSizeY(),
  }
end

return MapData