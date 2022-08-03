local vector = require 'lib.vector'
local bit = require 'bit'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'


local EPSILON = 0.001
local SIGN_RANGE = {-1, 1}

-- note that the values below are hardcoded for the player
-- the player should be the only one using this bump response anyways
local CORNER_CORRECT_DISTANCE = 6
local CORNER_CORRECT_SPEED = 1
-- the distance after corner correction to check for collision
local CORNER_CORRECT_COLLISION_CHECK_DISTANCE = 4.0

-- this bump response is like the slide response, except it will auto correct the item's position if it is
-- snagging the edge of a corner (like lttp and stardew valley does for the player)
local slideAndCornerCorrect = function(world, col, x, y, w, h, goalX, goalY, filter, alreadyVisited)
  goalX = goalX or x
  goalY = goalY or y

  local moveXNorm, moveYNorm = vector.normalize(col.moveX, col.moveY)
  local correctHorizontal = math.abs(moveYNorm) > EPSILON
  local correctVertical = math.abs(moveXNorm) > EPSILON
  -- only correct movement if they are only going up/down or left/right only
  if (correctHorizontal and not correctVertical) or (not correctHorizontal and correctVertical) then
    -- check dodging for both edges of the solid object
    for _, sign in ipairs(SIGN_RANGE) do
      local ox, oy, ow, oh = world:getRect(col.other)
      local correctX, correctY = 0, 0
      local distanceToEdge = 0
      if correctHorizontal then
        correctX = sign
        local entityEdgePosition = sign == 1 and x or x + w
        local otherEdgePosition = sign == -1 and ox or ox + ow
        distanceToEdge = math.abs(entityEdgePosition - otherEdgePosition)
      else
        correctY = sign
        local entityEdgePosition = sign == 1 and y or y + h
        local otherEdgePosition = sign == -1 and oy or oy + oh
        distanceToEdge = math.abs(entityEdgePosition - otherEdgePosition)
      end
      if distanceToEdge <= CORNER_CORRECT_DISTANCE then
        local moveAmount = math.min(CORNER_CORRECT_SPEED, distanceToEdge)
        --local nextX, nextY = vector.add(math.floor(x + 0.5), math.floor(y + 0.5), vector.mul(distanceToEdge, correctX, correctY))
        local nextX, nextY = vector.add(x, y, vector.mul(moveAmount, correctX, correctY))
        local newGoalX, newGoalY = vector.add(x, y, vector.mul(CORNER_CORRECT_COLLISION_CHECK_DISTANCE, correctX, correctY))
        newGoalX, newGoalY = vector.add(newGoalX, newGoalY, vector.mul(distanceToEdge, correctX, correctY))
        -- make sure the player is not colliding when placed at the solid object's edge
        local _, _, testCols, testLen = world:projectMove(col.item, x,y,w,h, nextX,nextY, filter)
        world.freeCollisions(testCols)
        local _, _, testCols2, testLen2 = world:projectMove(col.item, x,y,w,h, newGoalX,newGoalY, filter)
        world.freeCollisions(testCols2)
        if testLen == 0 and testLen2 == 0 then
          -- corner correct is not obstructed, so we can carry out the new corrected movement
          local cols, len = world:project(col.item, nextX,nextY,w,h, nextX, nextY, filter, alreadyVisited)
          return nextX, nextY, cols, len
        end
      end
    end
  end

  -- fallback to slide behaviour
  if col.moveX ~= 0 or col.moveY ~= 0 then
    if col.normalX ~= 0 then
      goalX = col.touchX
    else
      goalY = col.touchY
    end
  end
  col.slideX, col.slideY = goalX, goalY

  x, y = col.touchX, col.touchY
  local cols, len  = world:project(col.item, x,y,w,h, goalX, goalY, filter, alreadyVisited)
  return goalX, goalY, cols, len
end

return function(world)
  -- register responses
  world:addResponse('slide_and_corner_correct', slideAndCornerCorrect)

end