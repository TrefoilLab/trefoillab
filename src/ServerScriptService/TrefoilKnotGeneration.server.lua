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
local points = 70
local radius = 30

-- block size
local xSize = 45
local ySize = 32
local zSize = 45

-- Lobby Coordinates 584, 100, -140
local xOffset = 584			-- origin x offset
local yOffset = 300			-- origin y offset
local zOffset =	-140		-- origin z offset

-- will not work with hollow inside
local xSpacing = 1			-- axis spacing
local ySpacing = 0.8			-- y axis spacing
local zSpacing = 1			-- z axis spacing

local inverted = false		-- true for hollow inside (WIP)

local randomize = false
local random = Random.new()
local ranSpacing = Vector3.new(5, 7, 5)

local count = 0				-- count for how many points player touched

local cylinderID = "rbxassetid://689879827"		-- MeshID for hollow cylinder
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

	part.Parent = game.Workspace

	return part
end

local knot = generateTrefoil(points, radius)
local knot2 = generateTrefoil(points, radius)

-- Block generation
for i = 1, #knot - 1 do
	local point = knot[i]
	local nextPoint = knot[i + 1]
	
	point = Vector3.new((point.x * xSpacing), (point.y * ySpacing), (point.z * zSpacing))
	nextPoint = Vector3.new((nextPoint.x * xSpacing), (nextPoint.y * ySpacing), (nextPoint.z * zSpacing))

	local tangent = calculateTangent(point, nextPoint)

	local rotation = CFrame.lookAt(point, point + tangent) * CFrame.Angles(math.rad(90), 0, 0)

	local position = Vector3.new((point.x) + xOffset, (point.y) + yOffset, (point.z) + zOffset)
	local part = createMesh(position, Vector3.new(xSize, ySize, zSize), cylinderID, rotation)
	
	part.Touched:Connect(function(hit)
			changeColor(hit, part)
		end)

end

for i = 1, #knot2 - 1 do
	local point = knot2[i]
	local nextPoint = knot2[i + 1]

	point = Vector3.new((point.x * xSpacing), (point.y * ySpacing), (point.z * zSpacing))
	nextPoint = Vector3.new((nextPoint.x * xSpacing), (nextPoint.y * ySpacing), (nextPoint.z * zSpacing))

	local tangent = calculateTangent(point, nextPoint)

	local rotation = CFrame.lookAt(point, point + tangent) * CFrame.Angles(math.rad(90), 0, 0)

	local position = Vector3.new((point.x) + xOffset + randomizePlacement().X, (point.y) + yOffset + randomizePlacement().Y, (point.z) + zOffset + randomizePlacement().Z)
	local part = createMesh(position, Vector3.new(xSize, ySize, zSize), cylinderID, rotation)

	part.Touched:Connect(function(hit)
		changeColor(hit, part)
	end)

end

-- Block generation (OLD)
--for i, point in ipairs(knot) do
--	print("Adding another trefoil part.")
--	local part = Instance.new("Part")
--	local randPlacement = randomizePlacement()
--	part.Size = Vector3.new(size, size, size)
--	part.Position = Vector3.new((point.x * xSpacing) + xOffset + randomizePlacement().X, (point.y * ySpacing) + yOffset + randomizePlacement().Y, (point.z * zSpacing) + zOffset + randomizePlacement().Z)
--	part.BrickColor = BrickColor.new("Olive")
--	part.Anchored = true
--	part.CastShadow = false
--	part.CanCollide = true
	
--	part.Touched:Connect(function(hit)
--		changeColor(hit, part)
--	end)

	
--	part.Parent = game.Workspace
--end