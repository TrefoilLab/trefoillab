-- Function to procedurally generate a figure 8 knot
-- Chris Pascual

-- Creates points
function generateFig8Knot(points, radius)
	local pointsList = {}
	local step = (2 * math.pi) / points

	for i = 0, points - 1 do
		local t = i * step
		local x = (2 + math.cos(2 * t)) * math.cos(3 * t)
		local y = (2 + math.cos(2 * t)) * math.sin(3 * t)
		local z = math.sin(4 * t)

		table.insert(pointsList, Vector3.new(x * radius, y * radius, z * radius))
	end

	return pointsList
end


-- Changes block color when touched
local function changeColor(part)
	part.BrickColor = BrickColor.new("Baby blue")
end


-----Variables------
local points = 130
local radius = 30

local size = 5				-- block size

local xOffset = 30			-- origin x offset
local yOffset = 30			-- origin y offset
local zOffset =	0		-- origin z offset

local xOffset2 = 100			-- origin x offset
local yOffset2 = 100			-- origin y offset
local zOffset2 = 0		-- origin z offset


local xSpacing = 1			-- axis spacing
local ySpacing = 1			-- y axis spacing
local zSpacing = 1			-- z axis spacing

local inverted = false		-- true for hollow inside (WIP)

local randomize = false
local random = Random.new()
local ranSpacing = Vector3.new(5, 7, 5)

--------------------

function randomizePlacement()
	if not randomize then
		return Vector3.new(0, 0, 0);
	end
	return Vector3.new(random:NextNumber(-ranSpacing.X, ranSpacing.X), random:NextNumber(-ranSpacing.Y, ranSpacing.Y), random:NextNumber(-ranSpacing.Z, ranSpacing.Z))
end

--local knot = generateFig8Knot(points, radius)


-- Block generation
--for i, point in ipairs(knot) do
--	print("Adding another trefoil part.")
--	local part = Instance.new("TrussPart")
--	part.Size = Vector3.new(size, size, size)
--	part.Position = Vector3.new((point.x * xSpacing) + xOffset + randomizePlacement().X, (point.y * ySpacing) + yOffset + randomizePlacement().Y, (point.z * zSpacing) + zOffset + randomizePlacement().Z)
--	part.BrickColor = BrickColor.new("Olive")
--	part.Anchored = true
--	part.CastShadow = false
--	part.Touched:Connect(function(hit)
--		changeColor(part)
--	end)
--	part.Parent = game.Workspace
--end

-- B K-H
local knot = generateFig8Knot(points, radius)
for i, point in ipairs(knot) do
	print("Adding another trefoil part.")
	local part = Instance.new("Part")
	local partIsTouched = false
	part.Size = Vector3.new(size, size, size)
	part.Position = Vector3.new((point.x * xSpacing) + xOffset2 + randomizePlacement().X, (point.y * ySpacing) + yOffset2 + randomizePlacement().Y, (point.z * zSpacing) + zOffset2 + randomizePlacement().Z)
	part.BrickColor = BrickColor.new("Olive")
	part.Anchored = true
	part.CastShadow = false
	part.Touched:Connect(function(hit)
		changeColor(part)
		-- On touch part falls
		if partIsTouched == false then
			partIsTouched = true
			part.Anchored = false
		end
	end)
	part.Parent = game.Workspace
end
