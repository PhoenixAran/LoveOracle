local DisplayHandler = require 'engine.display_handler'
local vec2 = require 'lib.vector'

--- static camera instance
---@class Camera
local Camera = {
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

  positionSmoothingEnabled = false,
  positionSmoothingSpeed = 5.0,
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

function Camera.setLimits(limitTop, limitBottom, limitLeft, limitRight)
  Camera.limitTop = limitTop
  Camera.limitBottom = limitBottom
  Camera.limitLeft = limitLeft
  Camera.limitRight = limitRight
end

function Camera.setFollowTarget(target, followTargetPositionGetter)
  if followTargetPositionGetter == nil then
    followTargetPositionGetter = defaultFollowTargetPositionGetter
  end
  Camera.followTarget = target
  Camera.followTargetPositionGetter = followTargetPositionGetter
end

function Camera.update(dt)
  if Camera.followTarget then
    Camera.x, Camera.y = Camera.followTargetPositionGetter(Camera.followTarget)
  end

  if Camera.positionSmoothingEnabled then
    local c = Camera.positionSmoothingSpeed * dt
    Camera.smoothedX, Camera.smoothedY = vec2.add(Camera.smoothedX, Camera.smoothedY, vec2.mul(c, vec2.sub(Camera.x, Camera.y, Camera.smoothedX, Camera.smoothedY)))
  else
    Camera.smoothedX, Camera.smoothedY = Camera.x, Camera.y
  end
end

function Camera.push()
  local retX, retY = Camera.x, Camera.y
  local gameW, gameH = DisplayHandler.getGameSize()
  if Camera.positionSmoothingEnabled then
    retX, retY = Camera.smoothedX, Camera.smoothedY
  end

  local screenRectX,screenRectY,screenRectW,screenRectH =  retX, retY, vec2.mul(Camera.scale, gameW, gameH)
  if not Camera.positionSmoothingEnabled then
    if screenRectX < Camera.limitLeft then
      screenRectX = Camera.limitLeft
    end

    if screenRectX + screenRectW > Camera.limitRight then
      screenRectX = Camera.limitRight + screenRectW
    end

    if screenRectY + screenRectH > Camera.limitBottom then
      screenRectY = Camera.limitRight + screenRectH
    end

    if screenRectY < Camera.limitTop then
      screenRectY = Camera.limitTop
    end
  end

  love.graphics.push()
  love.graphics.translate(gameW / 2, gameH / 2)
  love.graphics.scale(Camera.scale)
  love.graphics.translate(-retX, -retY)
end

function Camera.pop()
  love.graphics.pop()
end

return Camera






