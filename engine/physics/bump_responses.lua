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
-- how far past the corner to check there is a collision
local AFTER_CORNER_CORRECT_DEPTH_CHECK = 2

-- NB: Kind of scuffed but an entity that uses this response needs a slideAndCornerCorrectQueryFilter for the queryRect call
-- it should be the same as your moveFilter response
-- this bump response is like the slide response, except it will auto correct the item's position if it is
-- snagging the edge of a corner (like lttp and stardew valley does for the player)
local slideAndCornerCorrect = function(world, col, x,y,w,h, goalX,goalY, filter, alreadyVisited)
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
      local correctX, correctY = 0.0, 0.0
      local distanceToEdge = 0.0
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
        local nextX, nextY = vector.add(x, y, vector.mul(moveAmount, correctX, correctY))
        local _, _, testCols, testLen = world:projectMove(col.item, x,y,w,h, nextX,nextY, filter)
        world.freeCollisions(testCols)
        -- make sure the player is not going to run into another bump box after they are corner corrected
        local afterCorrectionX, afterCorrectionY = x, y
        if correctHorizontal then
          afterCorrectionX = sign == 1 and ox + ow or ox - w
          afterCorrectionY = afterCorrectionY + (AFTER_CORNER_CORRECT_DEPTH_CHECK * -col.normalY)
        else
          afterCorrectionX = afterCorrectionX + (AFTER_CORNER_CORRECT_DEPTH_CHECK * -col.normalX)
          afterCorrectionY = sign == 1 and oy + oh or oy - h 
        end
        --local items, itemLen = world:queryRect(afterCorrectionX, afterCorrectionY,w,h, col.item.slideAndCornerCorrectQueryRectFilter)
        local items, itemLen = world:queryRect(afterCorrectionX,afterCorrectionY,w,h, 'slide')
        world.freeTable(items)

        if testLen == 0 and itemLen == 0 then
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