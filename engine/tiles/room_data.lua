local Class = require 'lib.class'
local lume = require 'lib.lume'

---@class RoomData
---@field topLeftPosX integer
---@field topLeftPosY integer
---@field width integer
---@field height integer
local RoomData = Class {
  init = function(self)
    self.topLeftPosX = -1
    self.topLeftPosY = -1
    self.width = -1
    self.height = -1
  end
}

function RoomData:getType()
  return 'room_data'
end

return RoomData