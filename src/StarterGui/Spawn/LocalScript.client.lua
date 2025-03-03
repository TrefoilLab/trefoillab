local TeleportToSpawn = game.ReplicatedStorage:WaitForChild("TeleportToSpawn")

local SpawnGui = script.Parent
local mainFrame = SpawnGui:WaitForChild("Frame")
local spawnButton = mainFrame:WaitForChild("SpawnButton")


spawnButton.MouseButton1Click:Connect(function()
	local player = game.Players.LocalPlayer
	if player then
		TeleportToSpawn:FireServer()
	end
end)
