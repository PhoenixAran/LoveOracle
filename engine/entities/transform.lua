-- @author Starkkz

Transform = {}
Transform.__index = Transform
Transform.x, Transform.y, Transform.z = 0, 0, 0

-- @description: Creates a new transformation
function Transform:new(entity)

	local self = setmetatable({}, Transform)

	self.Children = {}
  self.Entity = entity

	return self

end

-- @description: Assigns a transform as a parent of another transform
function Transform:setParent(Parent)
	if self.Parent then

		self.Parent.Children[ self.ID ] = nil

	end

	if Parent then

		self.ID = #Parent.Children + 1
		self.Parent = Parent
    -- fix by PhoenixAran :)
		Parent.Children[ self.ID ] = self

	else

		self.ID = nil
		self.Parent = nil

	end

end

-- @description: Gets the parent transform of a transform
function Transform:getParent()

	return self.Parent

end

-- @description: Tells the children that the transform has changed
function Transform:change()
  
	self.Haschanged = true
  self.Entity:transformChanged()

	for ID, Child in pairs(self.Children) do

		Child:change()

	end

end

-- @description: Sets the local rotation of a transform
function Transform:setLocalRotation(Angle)

	while Angle < -180 do

		Angle = Angle + 360

	end

	while Angle > 180 do

		Angle = Angle - 360

	end

	if Angle ~= self.Rotation then

		self.Rotation = Angle
		self.Radians = math.rad(Angle)

		if Angle == 0 then

			self.Matrix = {

				{1, 0},
				{0, 1},

			}

			self.InverseMatrix = {

				{1, 0},
				{0, 1},

			}

		else

			local Cosine = math.cos(self.Radians)
			local Sine = math.sin(self.Radians)

			-- The transformation matrix
			self.Matrix = {

				{ Cosine, -Sine },
				{ Sine, Cosine }

			}

			local a = self.Matrix[1][1]
			local b = self.Matrix[1][2]
			local c = self.Matrix[2][1]
			local d = self.Matrix[2][2]
			local Multiplier = 1 / ( a * d - b * c )

			self.InverseMatrix = {

				{d * Multiplier, -b * Multiplier},
				{-c * Multiplier, a * Multiplier},

			}

		end

		self:change()

		return true

	end

end

-- @description: Gets the local rotation of a transform
function Transform:getLocalRotation()

	return self.Rotation

end

-- @description: Sets the rotation of a transform
function Transform:setRotation(Angle)

	if self.Parent then

		Angle = Angle - self.Parent:getRotation()

	end

	return self:setLocalRotation(Angle)

end

-- @description: Gets the rotation of a transform
function Transform:getRotation()

	if self.Parent then

		local Rotation = self.Rotation + self.Parent:getRotation()

		while Rotation < -180 do

			Rotation = Rotation + 360

		end

		while Rotation > 180 do

			Rotation = Rotation - 360

		end

		return Rotation

	end

	return self.Rotation

end

-- @description: Sets the local position of a transform
function Transform:setLocalPosition(x, y, z)
	if x ~= self.x or y ~= self.y or ( z and z ~= self.z ) then

		if z then

			self.z = z

		end

		self.x, self.y = x, y
		self:change()

		return true

	end

	return false

end

-- @description: Gets the local position of a transform
function Transform:getLocalPosition()

	return self.x, self.y, self.z

end

-- @description: Sets the position of a transform
function Transform:setPosition(x, y, z)

	if self.Parent then

		x, y, z = self.Parent:toLocal(x, y, z)

	end

	return self:setLocalPosition(x, y, z)

end

-- @description: Gets the position of a transform
function Transform:getPosition()

	if self.Parent then
    
		return self.Parent:toWorld(self.x, self.y, self.z)

	end

	return self.x, self.y, self.z

end

-- @description: Gets the position of a transform as a vector
function Transform:getPositionVector()

	if self.Parent then

		local x, y, z = self.Parent:toWorld(self.x, self.y, self.z)

		return {x = x, y = y, z = z}

	end

	return {x = self.x, y = self.y, z = self.z}

end

-- @description: Transforms a point to world coordinates
function Transform:toWorld(x, y, z)

	if self.Parent then

		return self.Parent:toWorld( self.x + self.Matrix[1][1] * x + self.Matrix[1][2] * y, self.y + self.Matrix[2][1] * x + self.Matrix[2][2] * y, self.z + ( z or 0 ) )

	end

	return self.x + self.Matrix[1][1] * x + self.Matrix[1][2] * y, self.y + self.Matrix[2][1] * x + self.Matrix[2][2] * y, self.z + ( z or 0 )

end

-- @description: Transform multiple points to world coordinates (does not support 'z' coordinate)
function Transform:toWorldPoints(Points)

	local TransformedPoints = {}

	for i = 1, #Points, 2 do

		local x, y = Points[i], Points[i + 1]

		TransformedPoints[i] = self.x + self.Matrix[1][1] * x + self.Matrix[1][2] * y
		TransformedPoints[i + 1] = self.y + self.Matrix[2][1] * x + self.Matrix[2][2] * y

	end

	if self.Parent then

		return self.Parent:toWorldPoints(TransformedPoints)

	end

	return TransformedPoints

end

-- @description: Transforms a point to local coordinates
function Transform:toLocal(x, y, z)

	if self.Parent then

		x, y, z = self.Parent:toLocal(x, y, z)

	end

	x, y, z = x - self.x, y - self.y, z - self.z

	return self.InverseMatrix[1][1] * x + self.InverseMatrix[1][2] * y, self.InverseMatrix[2][1] * x + self.InverseMatrix[2][2] * y, z

end

-- @description: Transform a local angle to world
function Transform:toWorldAngle(Angle)

	local Rotation = Angle + self:getRotation()

	while Rotation < -180 do

		Rotation = Rotation + 360

	end

	while Rotation > 180 do

		Rotation = Rotation - 360

	end

	return Rotation

end

-- @description: Transform a world angle to local
function Transform:toLocalAngle(Angle)

	local Rotation = Angle - self:getRotation()

	while Rotation < -180 do

		Rotation = Rotation + 360

	end

	while Rotation > 180 do

		Rotation = Rotation - 360

	end

	return Rotation

end

return Transform