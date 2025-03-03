local STARTERPLAYERSCRIPTS = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

script:WaitForChild("WallStick").Parent = game:GetService("ReplicatedStorage")
script:WaitForChild("Animate").Parent = game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts")

for _, child in next, script:WaitForChild("StarterPlayer"):GetChildren() do
	local found = STARTERPLAYERSCRIPTS:FindFirstChild(child.Name)
	if (found) then found:Destroy() end
	child.Parent = STARTERPLAYERSCRIPTS
end

require(script:WaitForChild("ServerCode"))