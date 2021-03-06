local Class = require 'lib.class'
local lume = require 'lib.lume'

local NIL_TABLE = { }
local RoomData = Class {
  init = function(self, roomData)
    self.name = roomData.name or nil
    self.theme = roomData.theme or 'default'
    self.topLeftPosX = roomData.topLeftPosX or -1
    self.topLeftPosY = roomData.topLeftPosY or -1
    self.sizeX = roomData.sizeX or 16
    self.sizeY = roomData.sizeY or 16
  end
}

function RoomData:getType()
  return 'room_data'
end

function RoomData:getName()
  return self.name
end

function RoomData:setName(name)
  self.name = name
end

function RoomData:getTheme()
  return self.theme
end

function RoomData:setTheme(theme)
  self.theme = theme
end

function RoomData:getTopLeftPosition()
  return self.topLeftPosX, self.topLeftPosY
end

function RoomData:getTopLeftPositionX()
  return self.topLeftPosX
end

function RoomData:getTopLeftPositionY()
  return self.topLeftPosY
end

function RoomData:setTopLeftPosition(x, y)
  self.topLeftPosX = x
  self.topLeftPosY = y
end

function RoomData:setTopLeftPositionX(x)
  self.topLeftPosX = x
end

function RoomData:setTopLeftPositionY(y)
  self.topLeftPosY = y
end

function RoomData:getBottomRightPositionX()
  return self.topLeftPosX + self.sizeX - 1
end

function RoomData:getBottomRightPositionY()
  return self.topLeftPosY + self.sizeY - 1
end

function RoomData:getBottomRightPosition()
  return self.topLeftPosX + self.sizeX - 1, self.topLeftPosY + self.sizeY - 1
end

function RoomData:getSizeX()
  return self.sizeX
end

function RoomData:setSizeX(x)
  self.sizeX = x
end

function RoomData:getSizeY()
  return self.sizeY
end

function RoomData:setSizeY(y)
  self.sizeY = y
end

-- function RoomData:setHeight(y)
--   self.sizeY = y
-- end

function RoomData:getSerializableTable()
  return {
    name = self:getName(),
    theme = self:getTheme(),
    topLeftPosX = self:getTopLeftPositionX(),
    topLeftPosY = self:getTopLeftPositionY(),
    sizeX = self:getSizeX(),
    sizeY = self:getSizeY()
  }
end

function RoomData:clone()
  return RoomData(self:getSerializablTable())
end

return RoomData