local Class = require 'lib.class'
local ColorHelper = require 'engine.utils.color_helper'


local COLOR_TOKEN_START = '{'
local COLOR_TOKEN_END = '}'
local DEFAULT_COLOR = {1, 1, 1}

--- This class is used by inventory screens to help 
--- display text in the details panel
---@class InventoryTextReader
---@field wrapWidth integer
---@field textPosition integer
---@field textTimer integer
---@field textStart integer
---@field description string? the current description being read
---@field cleanDescription string? description without color codes
---@field colorMap table<integer, integer[]> color changes by description index
local InventoryTextReader = Class {
  init = function(self, wrapWidth)
    if wrapWidth == nil then
      wrapWidth = 128
    end
    self.wrapWidth = wrapWidth
    self.currentColor = {1, 1, 1}
    self.description = ''
    self.cleanDescription = ''
    self.textPosition = 0
    self.textTimer = 32
    self.textStart = 0
  end
}

function InventoryTextReader:getType()
  return 'inventory_text_reader'
end

function InventoryTextReader:setDescription(description)
  self.colorMap = { }
  self.description = description

  local cleanIndex = 1
  local i = 1
  local activeColor = {1, 1, 1}

  while i <= description:len() do
    local char = description:sub(i, i)
    if char == COLOR_TOKEN_START then
      local tagEndIndex =  description:find(COLOR_TOKEN_END, i)
      if tagEndIndex then
        local tagContent = description:sub(i + 1, tagEndIndex - 1)

        -- check if it's an opening color tag
        local hexCode = tagContent:match('^color #([%a%d]+)$')
        if hexCode then
          local r, g, b = ColorHelper.hexToRgb(hexCode)
          self.colorMap[cleanIndex] = {r, g, b}
        elseif tagContent == '/color' then
          self.colorMap[cleanIndex] = DEFAULT_COLOR
        else
          love.log.warn('Unrecognized or malformed tag: {' .. tagContent .. '}')
        end
        
        -- skip past the tag
        i = tagEndIndex + 1
      else
        love.log.warn('Malformed item description "' .. description .. '"')
      end
    else
      -- build the clean string
      self.cleanDescription = self.cleanDescription .. char
      cleanIndex = cleanIndex + 1
      i = i + 1
    end
  end

  -- reset scrolling variables
  self.textPosition = 0
  self.textTimer = 32
end

function InventoryTextReader:update()
  if self.cleanDescription ~= nil and self.cleanDescription ~= '' then
    if self.textTimer > 0 then
      -- update the pause timer
      self.textTimer = self.textTimer - 1
    elseif self.textPosition == 0 then
      -- pause the text
      self.textTimer = 32
    else
      self.textPosition = self.textPosition + 1

      if self.textPosition / 8 > self.cleanDescription:len() + self.textStart / 8 then
        -- wrap the text when it reaches the end
        self.textPosition = -self.wrapWidth + self.textStart
      end
    end
  end
end

--- draws text to given box dimensions
--- setting font should be done outside of this
--- TODO should probably change this, but this assumes font width is 8 pixels
---@param x number
---@param y number
---@param w number
---@param h number
function InventoryTextReader:draw(x, y, w, h)
  local position = self.textPosition - self.textStart
  local textIndex = position / 8
  if position < 0 then
    -- round down always
    textIndex = math.floor((position - 8 - 1) / 8)
    position = ((position - 7 - 1) / 8) * 8
  else
    position = (position / 8) * 8
  end

  local startIndex = math.max(1, textIndex + 1)
  local endIndex = math.max(0, math.min(textIndex + 16 + 1, self.cleanDescription:len()))
  local textToDraw = self.cleanDescription:sub(startIndex, endIndex)


  if position < 0 then
    love.graphics.print(textToDraw, love.graphics.getFont(), x - (position / 8) * 8, y)
  else
    love.graphics.print(textToDraw, love.graphics.getFont(), x, y)
  end
end

return InventoryTextReader
