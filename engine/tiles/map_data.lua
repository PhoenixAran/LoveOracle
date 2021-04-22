local Class = require 'lib.class'
local lume = require 'lib.lume'
local RoomData = require 'engine.tiles.room_data'
local TileLayer = require 'engine.tiles.layers.tile_layer'

local NIL_TABLE = { }
local GRID_SIZE = 16

-- TODO: ObjectLayer
-- Export Type Map Data
local MapData = Class {
  init = function(self, data)
    if not data then 
      data = NIL_TABLE
    end
    self.name = data.name or nil
    self.sizeX = data.sizeX or 16
    self.sizeY = data.sizeY or 16
    self.size = self.sizeX * self.sizeY
    --[[
      Thinking that the default should be this:
      layer 1: tiles
      layer 2: tiles 
      layer 3: entities / objects (TODO!)
    ]]
    
    -- deserialize layers
    local dataLayers = data.layers or {
      {layerType = 'tile_layer'},
      {layerType = 'tile_layer'}
    }
    local layers = { }
    self.layerCount = lume.count(dataLayers)
    for _, layerData in ipairs(dataLayers) do
      if layerData.layerType == 'tile_layer' then
        local tileLayer = TileLayer(layerData)
        -- update size just in case
        tileLayer.sizeX = self.sizeX
        tileLayer.sizeY = self.sizeY
        lume.push(layers, tileLayer)
      else
        error('Unsupported map layer type: ' .. layerType)
      end
    end

    self.layers = layers
    
    -- deserialize rooms
    data.rooms = data.rooms or { }
    local rooms = { }
    lume.each(data.rooms, function(roomData)
      lume.push(rooms, RoomData(roomData))
    end)
    self.rooms = rooms
    self.idCounter = data.idCounter or 0
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

function MapData:getLayerCount()
  return self.layerCount
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

function MapData:getRoom(roomKey)
  for k, v in ipairs(self.rooms) do
    if k == roomKey then
      return v
    end
  end
end

function MapData:resize(x, y)
  --TODO: figure out how to handle existing tile placement and entity placement when resizing map data
end

function MapData:setTile(layerIndex, tileIndex, x, y)
  assert(1 <= layerIndex and layerIndex <= self.layerCount)
  local layer = self.layers[layerIndex]
  assert(layer:getType() == 'tile_layer', 'Can only place tiles in layers with type "tile_layer"')
  if y == nil then
    assert(x <= self.sizeX, 'x is out of bounds')
    layer:setTile(tileIndex, x)
  else
    local index = (x - 1) * self.sizeY + y
    assert(index <= self.size, '(' .. tostring(x) .. ', ' .. tostring(y) .. ' is out of bounds')
    layer:setTile(tileIndex,index)
  end
end

function MapData:getTile(layerIndex, x, y)
  assert(1 <= layerIndex and layerIndex <= self.layerCount)
  local tileLayer = self.layers[layerIndex]
  assert(tileLayer:getType() == 'tile_layer', 'layer at index '.. tostring(layerIndex) .. ' is not a tile_layer')
  if y == nil then
    assert(x <= self.size, 'x is out of bounds')
    return tileLayer:getTile(x)
  end
  local index = (x - 1) * self.sizeY + y
  assert(index <= self.size, '( ' .. tostring(x) .. ', ' .. tostring(y) .. ') is out of bounds')
  return tileLayer:getTile(x, y)
end

--TODO: Add/Remove Room Data methods
function MapData:addRoom(roomData)
  local tlx, tly = roomData:getTopLeftPosition()
  local brx, bry = roomData:getBottomRightPosition()
  assert(1 <= tlx and tlx <= self.sizeX, 'room out of bounds')
  assert(1 <= tly and tly <= self.sizeY, 'room out of bounds')
  assert(1 <= brx and brx <= self.sizeX, 'room out of bounds')
  assert(1 <= bry and bry <= self.sizeY, 'room out of bounds')
  lume.push(self.rooms, roomData)
end

function MapData:removeRoom(roomData)
  lume.remove(self.rooms, roomData)
end

function MapData:generateRoomId()
  self.idCounter = self.idCounter + 1
  return 'room' .. self.idCounter
end

function MapData:indexInBounds(x, y)
  return 1 <= x and x <= self:getSizeX() and 1 <= y and y <= self:getSizeY()
end

function MapData:getSerializableTable()
  serializableLayers = { }
  for _, layer in ipairs(self.layers) do
    lume.push(serializableLayers, layer:getSerializableTable())
  end
  local sRooms = { }
  for _, room in ipairs(self.rooms) do
    lume.push(sRooms, room:getSerializableTable())
  end
  return {
    name = self:getName(),
    rooms = sRooms,
    layerCount = self.layerCount,
    layers = serializableLayers,
    sizeX = self:getSizeX(),
    sizeY = self:getSizeY(),
    idCounter = self.idCounter,
  }
end

MapData.GRID_SIZE = GRID_SIZE

return MapData