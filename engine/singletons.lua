---@class Singletons

-- dont have annotations for library object instances

---@class Singletons
---@field input any
---@field monocle any
---@field screenManager any
---@field camera any
---@field gameControl GameControl?
local singletons = {
  input = nil,
  monocle = nil,
  screenManager = nil,
  camera = nil,
  gameControl = nil
}

function singletons.getType()
  return 'singletons'
end

return singletons