local UserInputService = game:GetService("UserInputService")
local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

local hasDoubleJumped = false
local previousJump = tick()

local function doubleJump()
	if tick() - previousJump >= 0.2 then
		if Humanoid:GetState() == Enum.HumanoidStateType.Freefall and not hasDoubleJumped then
			hasDoubleJumped = true
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end

Humanoid.StateChanged:Connect(function(old, new)
	if new == Enum.HumanoidStateType.Landed then
		hasDoubleJumped = false
	elseif new == Enum.HumanoidStateType.Jumping then
		previousJump = tick()
	end
end)

UserInputService.JumpRequest:Connect(doubleJump)