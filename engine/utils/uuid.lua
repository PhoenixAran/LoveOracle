-- https://gist.github.com/jrus/3197011

local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
local random = love.math.random

local function gsubFunc(c)
  local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
  return string.format('%x', v)
end

--- generates a new universal unique identifier
---@return string
local function uuid()
  local val, _ = string.gsub(template, '[xy]', gsubFunc)
  return val
end

return uuid