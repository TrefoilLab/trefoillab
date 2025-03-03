local animate = script.Parent
local humanoid = animate.Parent:WaitForChild("Humanoid")

require(animate:WaitForChild("VerifyAnims"))(humanoid, animate)

if (humanoid.RigType == Enum.HumanoidRigType.R6) then
	return require(animate:WaitForChild("R6"))(animate)
else
	return require(animate:WaitForChild("R15"))(animate)
end