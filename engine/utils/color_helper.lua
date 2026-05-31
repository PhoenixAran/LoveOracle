local ColorHelper = { }

--- returns r g b values from hex string
---@param hex string|number
---@return number r
---@return number g
---@return number b
function ColorHelper.hexToRgb(hex)
  if type(hex) == 'string' then
    hex = tonumber(hex, 16)
  end
  -- clamp between 0x000000 and 0xffffff
  hex = hex%0x1000000 -- 0xffffff + 1

  -- extract each color
  local b = hex%0x100 -- 0xff + 1 or 256
  local g = (hex - b)%0x10000 -- 0xffff + 1
  local r = (hex - g - b)
  -- shift right
  g = g/0x100 -- 0xff + 1 or 256
  r = r/0x10000 -- 0xffff + 1

  return r / 255, g / 255, b / 255
end

return ColorHelper