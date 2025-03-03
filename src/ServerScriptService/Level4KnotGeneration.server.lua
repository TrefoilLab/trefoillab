-- Function to procedurally generate a trefoil knot
-- Chris Pascual

-- Creates points
function generateTrefoil(points, radius)
	local pointsList = {}
	local step = (2 * math.pi) / points

	for i = 0, points - 1 do
		local t = i * step
		local x = math.sin(t) + 2 * math.sin(2 * t)
		local y = math.cos(t) - 2 * math.cos(2 * t)
		local z = -math.sin(3 * t)

		table.insert(pointsList, Vector3.new(x * radius, y * radius, z * radius))
	end

	return pointsList
end

function generateLinkCalculus(points, radius)
	local pointsList = {}
	local step = (2 * math.pi) / points
	-- First circle
	for i = 0, points - 1 do
		local t = i * step
		local x = (2 - math.cos(t)) * math.cos(t)
		local y = (2 - math.cos(t)) * math.sin(t)
		local z = math.sin(t)

		table.insert(pointsList, Vector3.new(x * radius, y * radius, z * radius))
	end
	-- The other, linked, circle
	for i = 0, points - 1 do
		local t = i * step
		local x = (2 + math.cos(t)) * math.cos(t)
		local y = (2 + math.cos(t)) * math.sin(t)
		local z = math.cos(t)

		table.insert(pointsList, Vector3.new(x * radius, y * radius, z * radius))
	end

	return pointsList
end

-----Variables------
local points = 200 --60
local radius = 15

-- block size
local xSize = 10
local ySize = 5
local zSize = 5

-- Level 4 Platform
-- 317.792, 78.484, -370.938
-- Make it more positive x axis
local xOffset = 160		-- origin x offset
local yOffset = 100			-- origin y offset
local zOffset =	-400		-- origin z offset

local xOffset2 = 100		-- origin x offset
local yOffset2 = 180			-- origin y offset
local zOffset2 = -440		-- origin z offset

local xOffset3 = 50		-- origin x offset
local yOffset3 = 240			-- origin y offset
local zOffset3 = -400		-- origin z offset

-- will not work with hollow inside
local xSpacing = 0.8			-- axis spacing
local ySpacing = 0.8			-- y axis spacing
local zSpacing = 0.5			-- z axis spacing

local randomize = false
local random = Random.new()
local ranSpacing = Vector3.new(3, 4, 3)

local count = 0				-- count for how many points player touched

local rep = game.ReplicatedStorage
local rail = rep.BoardSlideTest
--------------------

-- Randomizes block placement
function randomizePlacement()
	if not randomize then
		return Vector3.new(0, 0, 0);
	end
	return Vector3.new(random:NextNumber(-ranSpacing.X, ranSpacing.X), random:NextNumber(-ranSpacing.Y, ranSpacing.Y), random:NextNumber(-ranSpacing.Z, ranSpacing.Z))
end

-- Changes block color when touched
local function changeColor(hit, part)
	part.BrickColor = BrickColor.new("Baby blue")
	count = count + 1
end

-- Simple function to calculate point tangent
local function calculateTangent(point, nextPoint)
	local direction = (nextPoint - point).unit		--.unit used for direction only, no magnitude
	return direction
end

-- Function for inserting custom models
local function createMesh(position, size, rotation)
	local part = rail:Clone()

	part.Size = size
	part.CFrame = CFrame.new(position) * rotation
	part.Anchored = true
	part.CastShadow = false
	part.CanCollide = true
	part.BrickColor = BrickColor.new("Black")
	--part.Transparency = .50

	part.Parent = game.Workspace

	return part
end

-- Function to generate last point
local function lastGen(point1, point2)
	local point = Vector3.new((point1.x * xSpacing), (point1.y * ySpacing), (point1.z * zSpacing))
	local nextPoint = Vector3.new((point2.x * xSpacing), (point2.y * ySpacing), (point2.z * zSpacing))

	local tangent = calculateTangent(point, nextPoint)

	local rotation = CFrame.lookAt(point, point + tangent) * CFrame.Angles(0, math.rad(90), 0)

	local position = Vector3.new((point.x) + xOffset, (point.y) + yOffset, (point.z) + zOffset)
	local part = createMesh(position, Vector3.new(xSize, ySize, zSize), rotation)

end

local knot = generateLinkCalculus(points, radius)
local knot2 = generateLinkCalculus(points, radius)
local knot3 = generateLinkCalculus(points, radius)



-- Block generation
for i = 1, #knot - 1 do
	local point = knot[i]
	local nextPoint = knot[i + 1]

	point = Vector3.new((point.x * xSpacing), (point.y * ySpacing), (point.z * zSpacing))
	nextPoint = Vector3.new((nextPoint.x * xSpacing), (nextPoint.y * ySpacing), (nextPoint.z * zSpacing))

	local tangent = calculateTangent(point, nextPoint)

	local rotation = CFrame.lookAt(point, point + tangent) * CFrame.Angles(0, math.rad(90), 0)

	local position = Vector3.new((point.x) + xOffset, (point.y) + yOffset, (point.z) + zOffset)
	local part = createMesh(position, Vector3.new(xSize, ySize, zSize), rotation)

end

--lastGen(knot[#knot], knot[1])

for i = 1, #knot2 - 1 do
	local point = knot2[i]
	local nextPoint = knot2[i + 1]

	point = Vector3.new((point.x * xSpacing), (point.y * ySpacing), (point.z * zSpacing))
	nextPoint = Vector3.new((nextPoint.x * xSpacing), (nextPoint.y * ySpacing), (nextPoint.z * zSpacing))

	local tangent = calculateTangent(point, nextPoint)

	local rotation = CFrame.lookAt(point, point + tangent) * CFrame.Angles(0, math.rad(90), 0)

	local position = Vector3.new((point.x) + xOffset2, (point.y) + yOffset2, (point.z) + zOffset2)
	local part = createMesh(position, Vector3.new(xSize, ySize, zSize), rotation)

end

for i = 1, #knot3 - 1 do
	local point = knot3[i]
	local nextPoint = knot3[i + 1]

	point = Vector3.new((point.x * xSpacing), (point.y * ySpacing), (point.z * zSpacing))
	nextPoint = Vector3.new((nextPoint.x * xSpacing), (nextPoint.y * ySpacing), (nextPoint.z * zSpacing))

	local tangent = calculateTangent(point, nextPoint)

	local rotation = CFrame.lookAt(point, point + tangent) * CFrame.Angles(0, math.rad(90), 0)

	local position = Vector3.new((point.x) + xOffset3, (point.y) + yOffset3, (point.z) + zOffset3)
	local part = createMesh(position, Vector3.new(xSize, ySize, zSize), rotation)

end