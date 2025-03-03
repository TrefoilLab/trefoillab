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
local points = 250 --250
local points2 = 200
local radius = 35 -- 35

-- block size
local xSize = 60 -- 60
local ySize = 12 -- 12
local zSize = 60 -- 60

-- Lobby Coordinates 584, 100, -140
local xOffset = 584			-- origin x offset
local yOffset = 200			-- origin y offset
local zOffset =	0		-- origin z offset


-- will not work with hollow inside
local xSpacing = 1			-- axis spacing 1
local ySpacing = 0.5			-- y axis spacing 0.5
local zSpacing = 1		-- z axis spacing 1

local inverted = false		-- true for hollow inside (WIP)

local randomize = true
local random = Random.new()
local ranSpacing = Vector3.new(3, 4, 3)

local count = 0				-- count for how many points player touched

local minJump = 4   -- Minimum acceptable jump distance
local maxJump = 8   -- Maximum acceptable jump distance

local firstTrussPart = nil
local teleportPlatform = game.Workspace:WaitForChild("Level1Teleport")

local cylinderID = "rbxassetid://4874721531"		-- 689879827
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
	part.BrickColor = BrickColor.new("Ghost grey")
	--part.Transparency = .50

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

	part.Touched:Connect(function(hit)
		--changeColor(hit, part)
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		local location = _G.Teleport
		player.Character:MoveTo(firstTrussPart)
	end)
end

local knot = generateTrefoil(points, radius)
local knot2 = generateTrefoil(points2, radius * 2)

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
		--changeColor(hit, part)
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		local location = _G.Teleport
		player.Character:MoveTo(firstTrussPart)
	end)

end

lastGen(knot[#knot], knot[1])

for i = 1, #knot2 - 2 do
	local currIteration = i
	local point = knot2[i]
	local nextPoint = knot2[i + 1]
	local nextNextPoint = knot2[i + 2]

	point = Vector3.new(point.x * xSpacing, point.y * ySpacing, point.z * zSpacing)
	nextPoint = Vector3.new(nextPoint.x * xSpacing, nextPoint.y * ySpacing, nextPoint.z * zSpacing)
	nextNextPoint = Vector3.new(nextNextPoint.x * xSpacing, nextNextPoint.y * ySpacing, nextNextPoint.z * zSpacing)

	local randPlacement = randomizePlacement()

	local randomizedPoint = Vector3.new(
		point.X + xOffset + randPlacement.X,
		point.Y + yOffset + randPlacement.Y,
		point.Z + zOffset + randPlacement.Z
	)

	local adjustedPoint = randomizedPoint - Vector3.new(xOffset, yOffset, zOffset)

	local distance1to2 = (nextPoint - adjustedPoint).Magnitude

	if distance1to2 < minJump then
		i = i + 1

		local distance1to3 = (nextNextPoint - adjustedPoint).Magnitude
		if distance1to3 > maxJump then
			local direction = (nextNextPoint - adjustedPoint).unit
			nextNextPoint = adjustedPoint + direction * maxJump

			knot2[i + 1] = nextNextPoint
		end

	else
		if currIteration == 1 then
			firstTrussPart = randomizedPoint
		end

		local part1 = Instance.new("TrussPart")
		part1.Size = Vector3.new(2, 2, 2)
		part1.CFrame = CFrame.new(randomizedPoint)
		part1.BrickColor = BrickColor.new("Olive")
		part1.Anchored = true
		part1.CastShadow = false
		part1.CanCollide = true
		part1.Parent = game.Workspace

		part1.Name = "TrussPart_" .. i

		part1.Touched:Connect(function(hit)
			changeColor(hit, part1)
		end)
	end
end

teleportPlatform:SetAttribute("TeleportDestination", firstTrussPart)









--for i = 1, #knot2 - 1 do
--	local point = knot2[i]
--	local nextPoint = knot2[i + 1]

--	point = Vector3.new((point.x * xSpacing), (point.y * ySpacing), (point.z * zSpacing))
--	nextPoint = Vector3.new((nextPoint.x * xSpacing), (nextPoint.y * ySpacing), (nextPoint.z * zSpacing))

--	local tangent = calculateTangent(point, nextPoint)

--	local rotation = CFrame.lookAt(point, point + tangent) * CFrame.Angles(0, math.rad(90), 0)

--	local randPlacement = randomizePlacement()
--	local position = Vector3.new((point.x) + xOffset + randPlacement.X, (point.y) + yOffset + randPlacement.Y, (point.z) + zOffset+ randPlacement.Z)

--	if i == 1 then
--		_G.Teleport = position
--	end

--	local part = Instance.new("TrussPart")
--	part.Size = Vector3.new(2, 2, 2)
--	part.CFrame = CFrame.new(position) * rotation
--	part.BrickColor = BrickColor.new("Olive")
--	part.Anchored = true
--	part.CastShadow = false
--	part.CanCollide = true
--	part.Parent = game.Workspace

--	part.Touched:Connect(function(hit)
--		changeColor(hit, part)
--	end)

--end


--for i, point in ipairs(knot2) do
--	print("Adding another trefoil part.")
--	local part = Instance.new("TrussPart")
--	local randPlacement = randomizePlacement()
--	part.Size = Vector3.new(8, 8, 8)
--	part.Position = Vector3.new((point.x * xSpacing) + xOffset + randPlacement.X, (point.y * ySpacing) + yOffset + randPlacement.Y, (point.z * zSpacing) + zOffset + randPlacement.Z)
--	if i == 1 then
--		_G.Teleport = part.Position
--	end
--	part.BrickColor = BrickColor.new("Olive")
--	part.Anchored = true
--	part.CastShadow = false
--	part.CanCollide = true

--	part.Touched:Connect(function(hit)
--		changeColor(hit, part)
--	end)

--	part.Parent = game.Workspace

--end


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