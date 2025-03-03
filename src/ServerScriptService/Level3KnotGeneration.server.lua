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

-----Variables------
local points = 500 --60
local radius = 20

-- block size
local xSize = 45
local ySize = 26
local zSize = 45

-- Level 3 Platform
-- 579.308, 82.02, -445.054
-- Make it more positive x axis
local xOffset = 580		-- origin x offset
local yOffset = 120			-- origin y offset
local zOffset =	-450		-- origin z offset


-- will not work with hollow inside
local xSpacing = 1			-- axis spacing
local ySpacing = 1			-- y axis spacing
local zSpacing = 1			-- z axis spacing

local randomize = true
local random = Random.new()
local ranSpacing = Vector3.new(3, 4, 3)

local count = 0				-- count for how many points player touched

local cylinderID = "rbxassetid://4874721531"		-- MeshID for hollow cylinder
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
local function createMesh(position, size, meshId, rotation)
	local InsertService = game:GetService("InsertService")
	local part = InsertService:CreateMeshPartAsync(meshId, 0, 0)

	part.Size = size
	part.CFrame = CFrame.new(position) * rotation
	part.Anchored = true
	part.CastShadow = false
	part.CanCollide = true
	part.BrickColor = BrickColor.new("Olive")
	part.Transparency = .90

	part.Parent = game.Workspace

	return part
end

-- Function to generate last point
local function lastGen(point1, point2)
	local point = Vector3.new((point1.x * xSpacing), (point1.y * ySpacing), (point1.z * zSpacing))
	local nextPoint = Vector3.new((point2.x * xSpacing), (point2.y * ySpacing), (point2.z * zSpacing))

	local tangent = calculateTangent(point, nextPoint)

	local rotation = CFrame.lookAt(point, point + tangent) * CFrame.Angles(math.rad(90), 0, 0)

	local position = Vector3.new((point.x) + xOffset, (point.y) + yOffset, (point.z) + zOffset)
	local part = createMesh(position, Vector3.new(xSize, ySize, zSize), cylinderID, rotation)

end

local knot = generateTrefoil(points, radius)

-- Block generation
for i = 1, #knot - 1 do
	local point = knot[i]
	local nextPoint = knot[i + 1]

	point = Vector3.new((point.x * xSpacing), (point.y * ySpacing), (point.z * zSpacing))
	nextPoint = Vector3.new((nextPoint.x * xSpacing), (nextPoint.y * ySpacing), (nextPoint.z * zSpacing))

	local tangent = calculateTangent(point, nextPoint)

	local rotation = CFrame.lookAt(point, point + tangent) * CFrame.Angles(math.rad(90), 0,0)

	local position = Vector3.new((point.x) + xOffset, (point.y) + yOffset, (point.z) + zOffset)
	local part = createMesh(position, Vector3.new(xSize, ySize, zSize), cylinderID, rotation)

end

lastGen(knot[#knot], knot[1])
