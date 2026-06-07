local Class = require 'lib.class'
local ColorHelper = require 'engine.utils.color_helper'
local lume = require 'lib.lume'


local COLOR_TOKEN_START = '{'
local COLOR_TOKEN_END = '}'
local DEFAULT_COLOR = {1, 1, 1}

--- This class is used by inventory screens to help 
--- display text in the details panel
---@class InventoryTextReader
---@field wrapWidth integer
---@field description string? the current description being read
---@field cleanDescription string? description without color codes
---@field colorMap table<integer, integer[]> color changes by description index
---@field formattedDescription table formatted description
local InventoryTextReader = Class {
  init = function(self, wrapWidth)
    if wrapWidth == nil then
      wrapWidth = 128
    end
    self.wrapWidth = wrapWidth
    self.currentColor = {1, 1, 1}
    self.description = ''
    self.cleanDescription = ''
    self.formattedDescription = { }
  end
}

function InventoryTextReader:getType()
  return 'inventory_text_reader'
end

function InventoryTextReader:setDescription(description)
  self.colorMap = { DEFAULT_COLOR }
  self.description = description
  self.cleanDescription = ''

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

  -- use the clean data to build the colord string table
  self.formattedDescription = { }
  local currentSegment = ''
  local activeColor = DEFAULT_COLOR
  for j = 1, self.cleanDescription:len() do
    if self.colorMap[j] and j > 1 then
      -- save chunk of text we've built so far with its color
      lume.push(self.formattedDescription, activeColor)
      lume.push(self.formattedDescription, currentSegment)

      activeColor = self.colorMap[j]
      currentSegment = ''
    end

    -- accumulate text
    currentSegment = currentSegment .. self.cleanDescription:sub(j, j)
  end

  -- catch the final segment after the loop ends
  if currentSegment ~= '' then
    lume.push(self.formattedDescription, activeColor)
    lume.push(self.formattedDescription, currentSegment)
  end
end

function InventoryTextReader:update()
  -- old marquee logic
  -- if self.cleanDescription ~= nil and self.cleanDescription ~= '' then
  --   if self.textTimer > 0 then
  --     -- update the pause timer
  --     self.textTimer = self.textTimer - 1
  --   elseif self.textPosition == 0 then
  --     -- pause the text
  --     self.textTimer = 32
  --   else
  --     self.textPosition = self.textPosition + 1

  --     if self.textPosition / 8 > self.cleanDescription:len() + self.textStart / 8 then
  --       -- wrap the text when it reaches the end
  --       self.textPosition = -self.wrapWidth + self.textStart
  --     end
  --   end
  -- end
end

local function applyPadding(x,y,w,h, padding)
  -- Shift the starting coordinates inward by the padding amount
    local newX = x + padding
    local newY = y + padding
    
    -- Shrink the width and height by padding on both sides (hence * 2)
    local newW = w - (padding * 2)
    local newH = h - (padding * 2)
    
    return newX, newY, newW, newH
end

--- draws text to given box dimensions
--- setting font should be done outside of this
--- TODO should probably change this, but this assumes font width is 8 pixels
---@param x number
---@param y number
---@param w number
---@param h number
---@param padding number?
function InventoryTextReader:draw(x, y, w, h, padding)
  if padding then
    x,y,w,h = applyPadding(x,y,w,h, padding)
  end
  if lume.count(self.formattedDescription) > 0 then
    love.graphics.printf(self.formattedDescription, x, y, w, 'left')
  end
end

return InventoryTextReader
