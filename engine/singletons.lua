---@class Singletons

-- dont have annotations for library object instances

---@class Singletons
---@field input any
---@field monocle any
---@field screenManager ScreenManager
---@field camera any
local singletons = {
  input = nil,
  monocle = nil,
  screenManager = nil,
  camera = nil
}

function singletons.getType()
  return 'singletons'
end

return singletons