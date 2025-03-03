local KEEP = {
	["Part"] = true,
	["MeshPart"] = true,
	["Motor6D"] = true,
	["Humanoid"] = true,
}

local KEEP_2 = {
	["Head"] = true,
	["HumanoidRootPart"] = true,
	["Humanoid"] = true
}

return function(character, transparency)
	local pre = character.Archivable
	character.Archivable = true
	local clone = character:Clone()
	character.Archivable = pre
	
	local realHum = character:WaitForChild("Humanoid")
	
	if (realHum.RigType == Enum.HumanoidRigType.R15) then
		local hrp = clone:WaitForChild("HumanoidRootPart")
		local neck = clone:FindFirstChild("Neck", true)
		neck.Part0 = hrp
		neck.Parent = hrp
	
		for _, part in next, clone:GetChildren() do
			if (not KEEP_2[part.Name]) then
				part:Destroy()
			elseif (part:IsA("BasePart")) then
				part.Transparency = transparency
			end
		end
	else
		local descendants = clone:GetDescendants()
		for _, part in next, descendants do
			if (not KEEP[part.ClassName]) then
				part:Destroy()
			elseif (part:IsA("BasePart")) then
				part.Transparency = transparency
			end
		end
	end
	
	local hum = clone:WaitForChild("Humanoid")
	hum:ClearAllChildren()
	
	hum.MaxHealth = math.huge
	hum.Parent = nil
	hum.Health = math.huge
	hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	hum.Parent = clone
	
	return clone
end