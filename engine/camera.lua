local DisplayHandler = require 'engine.display_handler'
local vec2 = require 'lib.vector'
local Consts = require 'constants'

--- static camera instance
---@class Camera
local Camera = {
  -- NOTE: Refers to top left position, not the center
  x = 0,
  y = 0,
  smoothedX = 0,
  smoothedY = 0,

  offsetX = 0,
  offsetY = 0,

  limitBottom = 10000000,
  limitLeft = -10000000,
  limitRight = 10000000,
  limitTop = -10000000,

  positionSmoothingEnabled = true,
  positionSmoothingSpeed = 5,
  scale = 1,

  followTarget = nil,
  followTargetPositionGetter = nil
}

local function defaultFollowTargetPositionGetter(obj)
  return obj.x + obj.w / 2, obj.y + obj.h / 2
end

function Camera.setPosition(x, y)
  local w, h = DisplayHandler.getGameSize()
  Camera.x = x - w / 2
  Camera.y = y - h / 2
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
  -- update follow target if it exists
  if Camera.followTarget then
    local w, h = DisplayHandler.getGameSize()
    local tx, ty = Camera.followTargetPositionGetter(Camera.followTarget)
    Camera.x, Camera.y = tx-w/2, ty-h/2
  end


  -- stay within limits
  local retX, retY = Camera.x, Camera.y
  local gameW, gameH = DisplayHandler.getGameSize()
  if Camera.positionSmoothingEnabled then
    retX, retY = Camera.smoothedX, Camera.smoothedY
  end

  local screenRectX,screenRectY,screenRectW,screenRectH =  retX, retY, vec2.mul(Camera.scale, gameW, gameH)
  screenRectH = screenRectH - Consts.HUD_HEIGHT

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

  -- set x, y position incase we have to clamp
  Camera.x = screenRectX
  Camera.y = screenRectY

  -- update smoothing position
  if Camera.positionSmoothingEnabled then
    local c = Camera.positionSmoothingSpeed * dt
    Camera.smoothedX, Camera.smoothedY = vec2.add(Camera.smoothedX, Camera.smoothedY, vec2.mul(c, vec2.sub(Camera.x, Camera.y, Camera.smoothedX, Camera.smoothedY)))
  else
    Camera.smoothedX, Camera.smoothedY = Camera.x, Camera.y
  end
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

function Camera.pop()
  love.graphics.pop()
end

return Camera






