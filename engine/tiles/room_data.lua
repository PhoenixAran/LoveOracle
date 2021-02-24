local Class = require 'lib.class'
local lume = require 'lib.lume'

local NIL_TABLE = { }
local RoomData = Class {
  init = function(self, data)
    self.name = roomData.name or nil
    self.theme = roomData.theme or nil
    self.topLeftPosX = data.topLeftPosX or -1
    self.topLeftPosY = data.topLeftPosY or -1
    self.width = data.width or 16
    self.height = data.height or 16
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
  return self.topLeftPosX + self.width
end

function RoomData:getBottomRightPositionY()
  return self.topLeftPosY + self.height
end

function RoomData:getBottomRightPosition()
  return self.topLeftPosX + self.width, self.topLeftPosY = self.height
end

function RoomData:getWidth()
  return self.width
end

function RoomData:setWidth(width)
  self.width = width
end

function RoomData:getHeight()
  return self.height
end

function RoomData:setHeight(height)
  self.height = height
end

function RoomData:getSerializableTable()
  return {
    name = self:getName(),
    theme = self:getTheme(),
    topLeftPosX = self:getTopLeftPositionX(),
    topLeftPosY = self:getTopLeftPositionY(),
    width = self:getWidth(),
    height = self:getHeight()
  }
end

return RoomData