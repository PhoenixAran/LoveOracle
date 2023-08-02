-- dont have annotations for library object instances
---@class Singletons
---@field input any
---@field monocle any
---@field screenManager any
---@field camera any
---@field gameControl GameControl?
---@field RoomControl RoomControl?
local singletons = {
  input = nil,
  monocle = nil,
  screenManager = nil,
  camera = nil,
  gameControl = nil,
  roomControl = nil
}

function singletons.getType()
  return 'singletons'
end

return singletons