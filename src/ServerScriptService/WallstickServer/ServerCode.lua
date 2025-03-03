local TERRAIN = game:GetService("Workspace"):WaitForChild("Terrain")
local PLAYERS = game:GetService("Players")
local RUNSERVICE = game:GetService("RunService")
local PHYSSERVICE = game:GetService("PhysicsService")

local mainCollisionGroup = PHYSSERVICE:GetCollisionGroupName(0)
local charCollisionGroup = "WallStickCharacters"
PHYSSERVICE:CreateCollisionGroup(charCollisionGroup)
PHYSSERVICE:CollisionGroupSetCollidable(mainCollisionGroup, charCollisionGroup, false)

--

local WallStick = game:GetService("ReplicatedStorage"):WaitForChild("WallStick")

local CharacterAppearanceLoaded = WallStick:WaitForChild("CharacterAppearanceLoaded")
local PhysicsReplicationEvent = WallStick:WaitForChild("PhysicsReplicationEvent")

local PhysicsReplicationStorage = {}

--

function CharacterAppearanceLoaded.OnServerInvoke(player)
	if (not player:HasAppearanceLoaded()) then
		player.CharacterAppearanceLoaded:Wait()
	end
	return true
end

PhysicsReplicationEvent.OnServerEvent:Connect(function(player, part, cf, remove)
	if (not remove) then
		local storage = PhysicsReplicationStorage[player]
		if (not storage) then
			storage = {
				CurrentPart = part;
				PreviousPart = part;
				CurrentCFrame = cf;
				PreviousCFrame = cf;
			}
			PhysicsReplicationStorage[player] = storage
		end
		
		storage.CurrentPart = part
		storage.CurrentCFrame = cf
	else
		PhysicsReplicationStorage[player] = nil
	end
	
	PhysicsReplicationEvent:FireAllClients(player, part, cf, remove)
end)

local function onFrameStep(dt)
	for player, storage in next, PhysicsReplicationStorage do
		if (player and storage) then
			local part = storage.CurrentPart
			local previousPart = storage.PreviousPart
			local currentCFrame = storage.CurrentCFrame
			local previousCFrame = storage.PreviousCFrame
			
			if (part == previousPart) then
				currentCFrame = previousCFrame:Lerp(currentCFrame, 0.1*(dt*60))
			end
			
			storage.PreviousPart = part
			storage.PreviousCFrame = currentCFrame
			
			local character = player.Character
			if (character) then
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if (hrp) then
					hrp.CFrame = part.CFrame:ToWorldSpace(currentCFrame)
				end
			end
		end
	end
end

--RUNSERVICE.Heartbeat:Connect(onFrameStep)

PLAYERS.PlayerRemoving:Connect(function(player)
	PhysicsReplicationStorage[player] = nil
end)

return true