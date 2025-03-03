local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local animationId = "rbxassetid://105156542990985"
local animation = Instance.new("Animation")
animation.AnimationId = animationId
local animator = humanoid:WaitForChild("Animator")
local animTrack = animator:LoadAnimation(animation)

player:GetAttributeChangedSignal("IsSliding"):Connect(function()
	if player:GetAttribute("IsSliding") then
		animTrack:Play()
	else
		animTrack:Stop()
	end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	animator = humanoid:WaitForChild("Animator")
	animTrack = animator:LoadAnimation(animation)
end)
