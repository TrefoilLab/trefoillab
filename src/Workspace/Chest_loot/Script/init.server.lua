script.ChestLocalScript.Chest.Value = script.Parent -- setting a value

local reward
if #script.Parent.Reward:GetChildren() > 0 then
	local originalReward = script.Parent.Reward:GetChildren()[1]
	reward = originalReward:Clone()
	local newModel = Instance.new("Model", script.Parent.Reward)
	for _, child in pairs(originalReward:GetChildren()) do
		if not (child:IsA("Script") or child:IsA("LocalScript")) then
			if child:IsA("BasePart") then
				child.Anchored = true
			end
			child.Parent = newModel
		else
			child:Destroy()
		end
	end
end

function onChestTouched(obj)
	local player = game.Players:GetPlayerFromCharacter(obj.Parent)
	if player then
		OnLidToggle(player)
	end
end

local chestHitBox = Instance.new("Part", script.Parent)
chestHitBox.Size = Vector3.new(5,3,4)
chestHitBox.Anchored = true
chestHitBox.CanCollide = false
chestHitBox.Transparency = 1
chestHitBox.CFrame = (script.Parent.PrimaryPart.CFrame + Vector3.new(0,1.5,0)) * CFrame.Angles(0,math.pi/2,0)

chestHitBox.Touched:connect(onChestTouched)

game.Players.PlayerAdded:connect(function(player) -- when a player si added
	player.CharacterAdded:connect(function() -- and whenever their character is loaded then
		if script.Parent.Configurations.StaticObject.Value == false then -- if this is not supposed to be a static object then
			local newScript = script.ChestLocalScript:Clone() -- clone the local script
			newScript.Parent = player.PlayerGui -- and put it in the player's playerGui
		end
	end)
end)

local hinge = script.Parent.Lid.HingePart -- making it easier to access this part
local lidOpen = false -- so we know if the chest is open or closed

if script.Parent.Configurations.StaticObject.Value == false then -- checking if this chest is supposed to open
	hinge.BodyPosition.position = Vector3.new(hinge.Position.X,hinge.Position.Y,hinge.Position.Z)
	hinge.BodyGyro.cframe = hinge.CFrame
	for i, v in pairs(script.Parent.Lid:GetChildren()) do
		v.Anchored = false
	end
else
	script.Parent.Lid.Lock.ClickDetector.MaxActivationDistance = 0
end

function OnLidToggle(player)
	if lidOpen == false then
		hinge.BodyGyro.cframe = hinge.BodyGyro.cframe * CFrame.Angles(0,0,math.rad(-90))
		lidOpen = true
	end
	
	if not player.Backpack:FindFirstChild(reward.Name) and player.Character and not player.Character:FindFirstChild(reward.Name) then
		local toGive = reward:Clone()
		for _, child in pairs(toGive:GetChildren()) do
			if child:IsA("BasePart") then
				child.Anchored = false
			end
		end
		
		if not game.StarterPack:FindFirstChild(reward.Name) then
			toGive:Clone().Parent = game.StarterPack
		end
		--toGive.Parent = player.Backpack
		player.Character.Humanoid:UnequipTools()
		--player.Character.Humanoid:EquipTool(toGive)
		toGive.Parent = player.Backpack
		player.Character.Humanoid:EquipTool(toGive)
		--toGive.Parent = player.Character
	end
	
	
end

script.Parent.LidToggle.OnServerEvent:connect(OnLidToggle)