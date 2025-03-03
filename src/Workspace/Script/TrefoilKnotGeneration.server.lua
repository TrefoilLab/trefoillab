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
local points = 200 --67
local points2 = 200
local radius = 35

-- block size
local xSize = 60
local ySize = 12
local zSize = 60

-- Lobby Coordinates 584, 100, -140
local xOffset = 30			-- origin x offset
local yOffset = 50			-- origin y offset
local zOffset =	0		-- origin z offset


-- will not work with hollow inside
local xSpacing = 1			-- axis spacing
local ySpacing = 0.5			-- y axis spacing
local zSpacing = 1		-- z axis spacing

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
local knot = generateTrefoil(points, radius)

for i, point in ipairs(knot) do
	print("Adding another trefoil part.")
	local part = Instance.new("Part")
	part.Size = Vector3.new(5, 5, 5)
	part.Position = Vector3.new((point.x * xSpacing) + xOffset, (point.y * ySpacing) + yOffset, (point.z * zSpacing) + zOffset)
	part.BrickColor = BrickColor.new("Olive")
	part.Anchored = true
	part.CastShadow = false
	part.CanCollide = true


	part.Parent = game.Workspace
end