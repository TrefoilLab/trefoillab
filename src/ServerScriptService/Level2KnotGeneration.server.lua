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
local points = 150
local radius = 30

-- block size
local xSize = 6
local ySize = 2
local zSize = 6

-- Level 2 Platform origin offsets
local xOffset = 830			-- origin x offset
local yOffset = 95			-- origin y offset
local zOffset = -459		-- origin z offset

local xSpacing = 1.5			-- x axis spacing
local ySpacing = 0.3		-- y axis spacing
local zSpacing = 1.5			-- z axis spacing

local randomize = true
local random = Random.new()
local ranSpacing = Vector3.new(3, 4, 3)

local count = 0			-- count for how many parts have been touched

--------------------

-- Randomizes block placement
function randomizePlacement()
	if not randomize then
		return Vector3.new(0, 0, 0)
	end
	return Vector3.new(
		random:NextNumber(-ranSpacing.X, ranSpacing.X),
		random:NextNumber(-ranSpacing.Y, ranSpacing.Y),
		random:NextNumber(-ranSpacing.Z, ranSpacing.Z)
	)
end

-- Changes block color when touched and increments count
local function changeColor(hit, part)
	part.BrickColor = BrickColor.new("Baby blue")
	count = count + 1
end

-- Shake and fall effect: shakes the part then unanchors it so it falls.
local function shakeAndFall(part)
	local shakeDuration = 1      -- total time (in seconds) for shaking
	local iterations = 20        -- number of shake steps
	local originalCFrame = part.CFrame

	for i = 1, iterations do
		local angleX = math.rad(math.random(-10, 10))
		local angleY = math.rad(math.random(-10, 10))
		local angleZ = math.rad(math.random(-10, 10))
		local shakeCFrame = originalCFrame * CFrame.Angles(angleX, angleY, angleZ)

		part.CFrame = shakeCFrame
		wait(shakeDuration / iterations)
	end

	part.Anchored = false
end

local knot = generateTrefoil(points, radius)

-- Block generation
for i, point in ipairs(knot) do
	local part = Instance.new("Part")
	-- Apply random placement variation
	local randPlacement = randomizePlacement()
	part.Size = Vector3.new(xSize, ySize, zSize)
	part.Position = Vector3.new(
		(point.x * xSpacing) + xOffset + randomizePlacement().X,
		(point.y * ySpacing) + yOffset + randomizePlacement().Y,
		(point.z * zSpacing) + zOffset + randomizePlacement().Z
	)
	part.BrickColor = BrickColor.new("Olive")
	part.Anchored = true
	part.CastShadow = false
	part.CanCollide = true
	part.Parent = game.Workspace

	-- Initialize an attribute to prevent re-triggering
	part:SetAttribute("HasFallen", false)

	-- Connect the Touched event to trigger color change and shake-then-fall effect
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and not part:GetAttribute("HasFallen") then
			part:SetAttribute("HasFallen", true)
			changeColor(hit, part)
			shakeAndFall(part)
		end
	end)
end
