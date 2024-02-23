local vec2 = require 'lib.vector'
local Consts = require 'constants'
local DisplayHandler = require 'engine.display_handler'

--- static camera instance
---@class Camera
---@field x number
---@field y number
---@field smoothedX number
---@field smoothedY number
---@field offsetX number
---@field offsetY number
---@field limitSmoothingEnabled boolean
---@field limitBottom number
---@field limitLeft number
---@field limitRight number
---@field limitTop number
---@field positionSmoothingEnabled boolean
---@field positionSmothingSpeed number
---@field scale number
---@field followTarget any
---@field followTargetPositionGetter function?
---@field _first boolean
local Camera = {
  -- NOTE: Refers to top left position, not the center
  x = 0,
  y = 0,
  smoothedX = 0,
  smoothedY = 0,

  offsetX = 0,
  offsetY = 0,

  limitSmoothingEnabled = true,
  limitBottom = 10000000,
  limitLeft = -10000000,
  limitRight = 10000000,
  limitTop = -10000000,

  positionSmoothingEnabled = true,
  positionSmoothingSpeed = 8,
  scale = 1,

  followTarget = nil,
  followTargetPositionGetter = nil
}

local function defaultFollowTargetPositionGetter(obj)
  return obj.x + obj.w / 2, obj.y + obj.h / 2
end

function Camera.setPosition(x, y)
  local w, h = Camera.getSize()
  Camera.x = x - w / 2
  Camera.y = y - h / 2
end

function Camera.syncSmoothingPositionWithActualPosition()
  Camera.smoothedX = Camera.x
  Camera.smoothedY = Camera.y
end

function Camera.setLimits(limitLeft, limitRight, limitTop, limitBottom)
  Camera.limitLeft = limitLeft
  Camera.limitRight = limitRight
  Camera.limitTop = limitTop
  Camera.limitBottom = limitBottom
end

function Camera.setBounds(x,y,w,h)
  Camera.setLimits(x,x+w,y,y+h)
end

function Camera.setFollowTarget(target, followTargetPositionGetter)
  if followTargetPositionGetter == nil then
    followTargetPositionGetter = defaultFollowTargetPositionGetter
  end
  Camera.followTarget = target
  Camera.followTargetPositionGetter = followTargetPositionGetter
end

function Camera.update(dt)
  local w, h = Camera.getSize()

  -- update follow target if it exists
  if Camera.followTarget then
    local tx, ty = Camera.followTargetPositionGetter(Camera.followTarget)
    Camera.x, Camera.y = tx-w/2, ty-h/2
  end


  local screenRectX,screenRectY,screenRectW,screenRectH = Camera.x, Camera.y, vec2.mul(Camera.scale, w, h)

  if Camera.limitSmoothingEnabled then
    if screenRectX < Camera.limitLeft then
      Camera.x = Camera.x - (screenRectX - Camera.limitLeft)
    end

    if screenRectX + screenRectW > Camera.limitRight then
      Camera.x = Camera.x - (screenRectX + screenRectW - Camera.limitRight)
    end

    if screenRectY + screenRectH > Camera.limitBottom then
      Camera.y = Camera.y - (screenRectY + screenRectH - Camera.limitBottom)
    end

    if screenRectY < Camera.limitTop then
      Camera.y = Camera.y - (screenRectY - Camera.limitTop)
    end
  end

  local retX, retY = Camera.x, Camera.y
  if Camera.positionSmoothingEnabled then
    retX, retY = Camera.smoothedX, Camera.smoothedY
  end

  -- update smoothing position
  if Camera.positionSmoothingEnabled then
    local c = Camera.positionSmoothingSpeed * dt
    Camera.smoothedX, Camera.smoothedY = vec2.add(Camera.smoothedX, Camera.smoothedY, vec2.mul(c, vec2.sub(Camera.x, Camera.y, Camera.smoothedX, Camera.smoothedY)))
  else
    Camera.smoothedX, Camera.smoothedY = Camera.x, Camera.y
  end

  if not Camera.positionSmoothingEnabled or not Camera.limitSmoothingEnabled then
      -- set x, y position incase we have to clamp
    if screenRectX < Camera.limitLeft then
      screenRectX = Camera.limitLeft
    end
    if screenRectX + screenRectW > Camera.limitRight then
      screenRectX = Camera.limitRight - screenRectW
    end
    if screenRectY + screenRectH > Camera.limitBottom then
      screenRectY = Camera.limitBottom - screenRectH
    end
    if screenRectY < Camera.limitTop then
      screenRectY = Camera.limitTop
    end
    Camera.x, Camera.y = screenRectX, screenRectY
  end
  retX, retY = Camera.smoothedX, Camera.smoothedY
end

function Camera.push()
  local x, y = Camera.x, Camera.y
  if Camera.positionSmoothingEnabled then
    x, y = Camera.smoothedX, Camera.smoothedY
  end
  love.graphics.push()
  love.graphics.scale(Camera.scale)
  love.graphics.translate(-x, -y)
end

function Camera.getSize()
  local w,h = DisplayHandler.getGameSize()
  h = h - Consts.HUD_HEIGHT
  return w,h
end

function Camera.pop()
  love.graphics.pop()
end

return Camera