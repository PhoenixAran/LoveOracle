---@diagnostic disable: missing-fields

-- dont have annotations for library object instances
---@class Singletons
---@field input any
---@field screenManager any
---@field camera any
---@field gameControl GameControl
---@field roomControl RoomControl
local singletons = {
  input = nil,
  displayHandler = { },
  screenManager = { },
  camera = { },
  gameControl = { },
  roomControl = { }
}

function singletons.getType()
  return 'singletons'
end

return singletons