--[[
	
This is a class that provides custom physics that allows things like walking upside down or on moving vehicle like planes, etc.

API:

Constructors and static functions:
	WallStick.new(Player player)
		> Creates a WallStick object for the given player.
	WallStick.WaitForAppearance(Player player)
		> Yields until the player's appearance has fully loaded.

Methods:
	WallStick:Destroy()
		> Destroys the WallStick object. This returns the player back to the standard humanoid based character controller.
	WallStick:SetCameraMode(mode)
		> Modes are "Custom" which rotates with the character. "Default" which is the standard camera (keep in mind default camera
		  will *NOT* properly calculate the humanoid move direction). "Debug" is used to view the physics character. Keep in mind 
		  DEBUG_TRANSPARENCY should not be set to 1 so you can actually see stuff.
	WallStick:GetFloorAndNormal()
		> This is a developer set method. You use it to define the current part the player is standing on and the object space normal 
		  that they should be oriented to on that part.
		> By default this returns nil, nil and thus does not change what the player is oriented to.
	WallStick:Set(part, objectNormal, newCF)
		> This method is used to manually set the part and object normal that the player is oriented to. The newCF parameter is optional
		  and can be used to CFrame the player to a new position.

Properties:
	WallStick.Part
		> The current part the player is relative to.
	WallStick.Normal
		> The current object space normal the player is oriented to.
	WallStick.PhysicsFloor
		> The floor part that the physics character is currently on top of.
		> This is useful for converting values from the physics space to the real space and back.
	WallStick.Character
		> The player's Character
	WallStick.Humanoid
		> The player's Humanoid
	WallStick.HRP
		> The player's HumanoidRootPart
	WallStick.PhysicsCharacter
		> The player's physics Character
	WallStick.PhysicsHumanoid
		> The player's physics Humanoid
	WallStick.PhysicsHRP
		> The player's physics HumanoidRootPart
	

Enjoy!
- EgoMoose

--]]

local TERRAIN = game:GetService("Workspace"):WaitForChild("Terrain")
local PLAYERS = game:GetService("Players")
local RUNSERVICE = game:GetService("RunService")
local PHYSSERVICE = game:GetService("PhysicsService")

local COLLIDE_WITH_PLAYERS = true
local WORLD_CENTER = Vector3.new(10000, 0, 0)
local COLLIDER_SIZE2 = Vector3.new(64, 64, 64) / 2
local WALLSTICKCHARID = PHYSSERVICE:GetCollisionGroupId("WallStickCharacters")

local DEBUG = false
local DEBUG_TRANSPARENCY = DEBUG and 0 or 1

local ZERO = Vector3.new(0, 0, 0)
local UNIT_X = Vector3.new(1, 0, 0)
local UNIT_Y = Vector3.new(0, 1, 0)
local UNIT_Z = Vector3.new(0, 0, 1)
local VEC_XZ = Vector3.new(1, 0, 1)
local VEC_YZ = Vector3.new(0, 1, 1)

--

local CharacterAppearanceLoaded = script:WaitForChild("CharacterAppearanceLoaded")
local PhysicsReplicationEvent = script:WaitForChild("PhysicsReplicationEvent")

local PhysicsCharacter = require(script:WaitForChild("PhysicsCharacter"))
local AnimationReplicator = require(script:WaitForChild("AnimationReplicator"))

-- Private Functions

local function getRotationBetween(u, v, axis)
	local dot, uxv = u:Dot(v), u:Cross(v)
	if (dot < -0.99999) then return CFrame.fromAxisAngle(axis, math.pi) end
	return CFrame.new(0, 0, 0, uxv.x, uxv.y, uxv.z, 1 + dot)
end

local function setCollisionGroupId(array, id)
	for _, part in next, array do
		if (part:IsA("BasePart")) then
			part.CollisionGroupId = id
		end
	end
end

-- Class

local WallStick = {}
WallStick.__index = WallStick

-- Public Constructors

function WallStick.new(player)
	local self = setmetatable({}, WallStick)
	
	-- fix slow load bug
	local loaded = player.PlayerScripts:WaitForChild("PlayerScriptsLoader"):WaitForChild("Loaded")
	if (not loaded.Value) then
		loaded.Changed:Wait()
	end
	
	--
	
	self.Part = nil
	self.Normal = UNIT_Y -- Object Space
	
	self.PhysicsFloor = nil
	self.CollisionParts = {}
	self.LastTick = tick()
	self.IsOtherFrame = false
	
	--	
	self.PhysicsWorld = Instance.new("Model")
	self.PhysicsWorld.Name = "PhysicsWorld"
	self.PhysicsWorld.Parent = game.Workspace
	
	self.PhysicsCollision = Instance.new("Model")
	self.PhysicsCollision.Name = "PhysicsCollision"
	self.PhysicsCollision.Parent = self.PhysicsWorld
	
	--
	self.Player = player
	self.Character = player.Character
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.HRP = self.Character:WaitForChild("HumanoidRootPart")
	
	self.PhysicsCharacter = PhysicsCharacter(self.Character, DEBUG_TRANSPARENCY)
	self.PhysicsHumanoid = self.PhysicsCharacter:WaitForChild("Humanoid")
	self.PhysicsHRP = self.PhysicsCharacter:WaitForChild("HumanoidRootPart")
	self.PhysicsCharacter.Parent = self.PhysicsWorld
	
	self.Gyro = script:WaitForChild("BodyGyro"):Clone()
	
	setCollisionGroupId(self.Character:GetChildren(), WALLSTICKCHARID)
	
	--
	local playerScripts = require(player.PlayerScripts:WaitForChild("PlayerModule"))
	self.Controls = playerScripts:GetControls()
	
	self.Camera = playerScripts:GetCameras()
	self.Camera.TransitionRate = 1
	self.CameraUp = UNIT_Y
	
	self:SetCameraMode(DEBUG and "Debug" or "Custom")
	
	function self.Camera.GetUpVector(this, oldUpVector)
		return self.CameraUp
	end
	
	--
	self.AnimationReplicator = AnimationReplicator.new(self.Character)
	self.AnimationReplicator:SetRepHumanoid(self.PhysicsHumanoid)
	
	--
	self.Humanoid.PlatformStand = true
	
	self.DeathConnection = self.Humanoid.Died:Connect(function()
		self:Destroy()
	end)
	
	self.AncestryConnection = self.Character.AncestryChanged:Connect(function(_, parent)
		if (not parent) then
			self:Destroy()
		end
	end)
	
	--
	RUNSERVICE:BindToRenderStep("WallStickUpdate", Enum.RenderPriority.Camera.Value - 1, function(dt) 
		self:OnStep(dt) 
		self:OnCollisionStep(dt)
		self:OnCharacterMovement(dt)
	end)

	self:Set(TERRAIN, UNIT_Y)
	
	return self
end

function WallStick.WaitForAppearance(player)
	CharacterAppearanceLoaded:InvokeServer()
end

-- Public Methods

function WallStick:Destroy()
	setCollisionGroupId(self.Character:GetChildren(), 0)
	PhysicsReplicationEvent:FireServer(nil, nil, true)
	
	self.Humanoid.PlatformStand = false
	
	self.HRP.Velocity = self.Part.CFrame:VectorToWorldSpace(self.PhysicsFloor.CFrame:VectorToObjectSpace(self.PhysicsHRP.Velocity))
	self.HRP.RotVelocity = self.Part.CFrame:VectorToWorldSpace(self.PhysicsFloor.CFrame:VectorToObjectSpace(self.PhysicsHRP.RotVelocity))
	
	self.AnimationReplicator:SetRepHumanoid(self.Humanoid)
	self:SetCameraMode("Default")
	self.CameraUp = UNIT_Y

	self.DeathConnection:Disconnect()
	self.AncestryConnection:Disconnect()
	
	RUNSERVICE:UnbindFromRenderStep("WallStickUpdate")
	
	self.PhysicsWorld:Destroy()
end

function WallStick:SetCameraMode(mode)
	local cam = workspace.CurrentCamera
	
	if (mode == "Custom") then
		cam.CameraSubject = self.Humanoid
	elseif (mode == "Default") then
		cam.CameraSubject = self.Humanoid
		self.CameraUp = UNIT_Y
		self.Camera:SetSpinPart(TERRAIN)
	elseif (mode == "Debug") then
		cam.CameraSubject = self.PhysicsHumanoid
	end
	
	self.CameraMode = mode
end

function WallStick:GetFloorAndNormal(lastPart, lastNormal, lastTick)
	-- written by the dev using the controlller
	-- return part, objectSpaceNormal
end

function WallStick:Set(newPart, newNormal, newCF)
	local lastPart = self.Part
	local lastNormal = self.Normal
	
	self.Part = newPart
	self.Normal = newNormal
	
	local physVel = self.PhysicsHRP.Velocity
	local physRotVel = self.PhysicsHRP.RotVelocity
	
	-- create a new/updated physics floor
	if (self.PhysicsFloor) then
		self.PhysicsFloor:Destroy()
	end
	
	local isTerrain = (newPart.ClassName == "Terrain")
	local isSpawn = (newPart.ClassName == "SpawnLocation")
	local isSeat = (newPart.ClassName == "Seat" or newPart.ClassName == "VehicleSeat")
	
	local floor
	if (isTerrain or isSpawn or isSeat) then
		floor = Instance.new("Part")
		floor.CanCollide = isSpawn and newPart.CanCollide or false
		floor.Size = not isTerrain and newPart.Size or ZERO
	else
		floor = newPart:Clone()
		floor:ClearAllChildren()
	end
	
	floor.Name = "PhysicsFloor"
	floor.Transparency = DEBUG_TRANSPARENCY
	floor.Anchored = true
	floor.Velocity = ZERO
	floor.RotVelocity = ZERO
	floor.CFrame = CFrame.new(WORLD_CENTER) * getRotationBetween(self.Normal, UNIT_Y, UNIT_X)
	floor.Parent = self.PhysicsWorld
	
	self.PhysicsFloor = floor
	
	local camera = workspace.CurrentCamera
	local cameraOffset = self.PhysicsHRP.CFrame:ToObjectSpace(camera.CFrame)
	local focusOffset = self.PhysicsHRP.CFrame:ToObjectSpace(camera.Focus)
	
	-- character/camera positioning
	if (self.CollisionParts[newPart]) then
		self.CollisionParts[newPart]:Destroy()
		self.CollisionParts[newPart] = nil
	end
	
	-- adjust this
	local vel = self.PhysicsHRP.CFrame:VectorToObjectSpace(self.PhysicsHRP.Velocity)
	local rVel = self.PhysicsHRP.CFrame:VectorToObjectSpace(self.PhysicsHRP.RotVelocity)
	
	self.PhysicsHRP.CFrame = self.PhysicsFloor.CFrame:ToWorldSpace(newPart.CFrame:ToObjectSpace(newCF or self.HRP.CFrame))
	self.PhysicsHRP.Velocity = self.PhysicsHRP.CFrame:VectorToWorldSpace(vel)
	self.PhysicsHRP.RotVelocity = self.PhysicsHRP.CFrame:VectorToWorldSpace(rVel)

	-- update the camera
	if (self.CameraMode == "Custom") then
		self.Camera:SetSpinPart(newPart)
	elseif (self.CameraMode == "Debug") then
		camera.CFrame = self.PhysicsHRP.CFrame:ToWorldSpace(cameraOffset)
		camera.Focus = self.PhysicsHRP.CFrame:ToWorldSpace(focusOffset)
	end
	
	-- update the tick
	self.LastTick = tick()
end

--

function WallStick:OnCollisionStep(dt)
	local parts = workspace:FindPartsInRegion3(Region3.new(
		self.HRP.Position - COLLIDER_SIZE2,
		self.HRP.Position + COLLIDER_SIZE2
	), self.Character, 1000)
	
	local newCollisionParts = {}
	local collisionParts = self.CollisionParts
	
	local stickPart = self.Part
	local stickPartCF = stickPart.CFrame
	local physicsFloorCF = self.PhysicsFloor.CFrame
	
	for _, part in next, parts do
		if (collisionParts[part]) then
			local cPart = collisionParts[part]
			cPart.CFrame = physicsFloorCF:ToWorldSpace(stickPartCF:ToObjectSpace(part.CFrame))
			cPart.CanCollide = part.CanCollide
			newCollisionParts[part] = cPart
		elseif (part ~= stickPart and not part:IsDescendantOf(self.Character) and not part:IsDescendantOf(self.PhysicsWorld) and part.CanCollide and (COLLIDE_WITH_PLAYERS or not PLAYERS:GetPlayerFromCharacter(part.Parent))) then
			local cPart
			
			local isSeat = (part.ClassName == "Seat" or part.ClassName == "VehicleSeat")
			
			if (part.ClassName == "SpawnLocation" or isSeat) then
				cPart = Instance.new("Part")
				cPart.CanCollide = part.CanCollide
				cPart.Size = part.Size
			else
				cPart = part:Clone()
				cPart:ClearAllChildren()
			end
			
			cPart.Transparency = DEBUG_TRANSPARENCY
			cPart.Anchored = true
			cPart.Velocity = ZERO
			cPart.RotVelocity = ZERO
			cPart.Parent = self.PhysicsCollision
			
			newCollisionParts[part] = cPart
			self.CollisionParts[part] = cPart
		end
	end
	
	if (self.PhysicsFloor) then
		self.PhysicsFloor.CanCollide = stickPart.CanCollide
	end
	
	for part, cPart in next, self.CollisionParts do
		if (not newCollisionParts[part]) then
			self.CollisionParts[part] = nil
			cPart:Destroy()
		end
	end
end

function WallStick:OnStep(dt)
	self.HRP.Velocity = ZERO
	self.HRP.RotVelocity = ZERO
	
	local hrpOffset = self.PhysicsFloor.CFrame:ToObjectSpace(self.PhysicsHRP.CFrame)
	self.HRP.CFrame = self.Part.CFrame:ToWorldSpace(hrpOffset)
	
	local newPart, newNormal = self:GetFloorAndNormal(self.Part, self.Normal, self.LastTick)
	if (newPart and newNormal) then
		self:Set(newPart, newNormal)
	elseif (not self.Part.Parent) then
		self:Set(TERRAIN, UNIT_Y)
	end
	
	-- server replication
	self.OtherFrame = not self.OtherFrame
	if (self.OtherFrame) then
		local hrpOffset = self.PhysicsFloor.CFrame:ToObjectSpace(self.PhysicsHRP.CFrame)
		PhysicsReplicationEvent:FireServer(self.Part, hrpOffset, false)
	end
	
	self.PhysicsHumanoid.WalkSpeed = self.Humanoid.WalkSpeed
	self.PhysicsHumanoid.JumpPower = self.Humanoid.JumpPower
	self.PhysicsHumanoid.Jump = self.Humanoid.Jump
	
	-- camera
	if (self.CameraMode == "Custom") then
		self.CameraUp = self.Part.CFrame:VectorToWorldSpace(self.Normal)
	end

	-- mouse lock
	local pHRPCF = self.PhysicsHRP.CFrame
	local pCamCF = pHRPCF * self.HRP.CFrame:ToObjectSpace(workspace.CurrentCamera.CFrame)

	self.Gyro.CFrame = CFrame.new(pHRPCF.p, pHRPCF.p + pCamCF.LookVector * VEC_XZ)
	self.Gyro.Parent = self.Camera:IsCamRelative() and self.PhysicsHRP or nil
end

function WallStick:OnCharacterMovement(dt)
	local move = self.Controls:GetMoveVector()
	
	if (self.CameraMode ~= "Debug") then
		local physCamCF = self.PhysicsHRP.CFrame * self.HRP.CFrame:ToObjectSpace(workspace.CurrentCamera.CFrame)
		
		local c, s
		local _, _, _, R00, R01, R02, _, R11, R12, _, _, R22 =  physCamCF:GetComponents()
		
		local q = math.sign(R11)
		if R12 < 1 and R12 > -1 then
			c = R22
			s = R02
		else
			c = R00
			s = -R01*math.sign(R12)
		end
		
		local norm = math.sqrt(c*c + s*s)
		local physMove = Vector3.new(
			(c*move.x*q + s*move.z)/norm,
			0,
			(c*move.z - s*move.x*q)/norm
		)
	
		self.PhysicsHumanoid:Move(physMove, false)
	else
		self.PhysicsHumanoid:Move(move, true)
	end
end

--

return WallStick
