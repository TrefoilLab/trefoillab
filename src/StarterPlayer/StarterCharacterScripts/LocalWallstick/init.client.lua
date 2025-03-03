-- CONSTANTS

local COLLECTION = game:GetService("CollectionService")
local REPSTORAGE = game:GetService("ReplicatedStorage")
local RUNSERVICE = game:GetService("RunService")
local PLAYERS = game:GetService("Players")
local LOCALPLAYER = PLAYERS.LocalPlayer

local TERRAIN = workspace.Terrain
local DISABLE_STATES = {
	[Enum.HumanoidStateType.Physics] = true;
	[Enum.HumanoidStateType.Seated] = true;
}

local WallStickClass = require(REPSTORAGE:WaitForChild("WallStick"))
local Raycast = require(script:WaitForChild("Raycast"))

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Special tags for different parts

local function getTags(tag)
	local dict = {}
	for _, object in next, COLLECTION:GetTagged(tag) do
		dict[object] = true
		for _, child in next, object:GetDescendants() do
			dict[child] = true
		end
	end
	return dict
end

local fastTransitionParts = getTags("FastTransitionParts")
local ignoreParts = getTags("IgnoreParts")
local maintainParts = getTags("MaintainParts")

-- Wallstick control

local wallstick = nil

local targetRate = 1
local floor = TERRAIN
local lNormal = Vector3.new(0, 1, 0)

local function lerp(a, b, t)
	return (b - a)*t + a
end

local function clampCloseToOne(t, margin)
	if (math.abs(1 - t) < margin) then
		return 1
	end
	return t
end

local function raycastFromCharacter()
	local characters = {}
	for i, player in next, PLAYERS:GetPlayers() do
		characters[i] = player.Character
	end
	
	local hrpCF = HRP.CFrame
	local height = Character:GetExtentsSize().y * 0.75
	local ray = Ray.new(hrpCF.p, -height*hrpCF.UpVector)
	
	return Raycast.FindPartOnRayWithCallbackWithIgnoreList(ray, characters, false, true, 5, function(hit, position, normal, material)
		if (not hit) then
			return Raycast.CallbackResult.Finished
		elseif (hit.CanCollide) then
			return Raycast.CallbackResult.Finished
		else
			table.insert(characters, hit)
			return Raycast.CallbackResult.Continue
		end
	end)
end

local function getFloorAndNormal(self)
	if (tick() - self.LastTick < 0.3) then
		return
	end
	if (floor ~= self.Part) then
		return floor, lNormal
	end
end

local function setWallstickEnabled(bool)
	if (DISABLE_STATES[Humanoid:GetState()]) then
		bool = false
	end
	
	if (not bool and wallstick) then
		wallstick:Destroy()
		wallstick = nil
	elseif (bool and not wallstick) then
		wallstick = WallStickClass.new(LOCALPLAYER)
		wallstick.GetFloorAndNormal = getFloorAndNormal
		targetRate = wallstick.Camera.TransitionRate
	end
end

local function onPhysicsStep(dt)
	local hit, pos, normal = raycastFromCharacter()
	setWallstickEnabled(hit ~= TERRAIN)
	if (not wallstick) then return end
	
	-- handle camera transitioning
	if (fastTransitionParts[hit] or (hit and not hit.Anchored)) then
		targetRate = 1
	else
		wallstick.Camera.TransitionRate = 0.15
		targetRate = 0.15
	end
	
	wallstick.Camera.TransitionRate = clampCloseToOne(lerp(wallstick.Camera.TransitionRate, targetRate, 0.1), 1E-4)
	
	-- set the new floor and it's relative up vector (unless it's an ignore part)
	if (hit and hit.CanCollide and not ignoreParts[hit]) then
		local rNormal = hit.CFrame:VectorToObjectSpace(normal)
		
		if (maintainParts[hit]) then
			local n = wallstick.Part.CFrame:VectorToWorldSpace(wallstick.Normal)
			rNormal = hit.CFrame:VectorToObjectSpace(n)
		end
		
		if (hit ~= wallstick.Part) then
			floor, lNormal = hit, rNormal
		end
	end
	
	if (not floor:IsDescendantOf(workspace)) then
		floor = TERRAIN
		lNormal = Vector3.new(0, 1, 0)
	end
end

-- Init

WallStickClass.WaitForAppearance(LOCALPLAYER)

setWallstickEnabled(true)

Humanoid.StateChanged:Connect(function(oldState, newState)
	if (DISABLE_STATES[newState]) then
		setWallstickEnabled(false)
	end
end)

RUNSERVICE.Heartbeat:Connect(onPhysicsStep)