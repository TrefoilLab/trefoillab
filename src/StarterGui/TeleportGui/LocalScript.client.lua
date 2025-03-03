-- LocalScript inside TeleportGui

local uis = game:GetService("UserInputService")

local TeleportPrompt = game.ReplicatedStorage:WaitForChild("TeleportPrompt")
local TeleportResponse = game.ReplicatedStorage:WaitForChild("TeleportResponse")

local TeleportGui = script.Parent
local mainFrame = TeleportGui:WaitForChild("MainFrame")
local promptLabel = mainFrame:WaitForChild("PromptLabel")
local yesButton = mainFrame:WaitForChild("YesButton")
local noButton = mainFrame:WaitForChild("NoButton")

-- Hide the GUI by default.
TeleportGui.Enabled = false

-- A variable to store the current destination.
local currentDestination = nil

-- Listen for the prompt event from the server.
TeleportPrompt.OnClientEvent:Connect(function(destination, teleportLevel)
	currentDestination = destination
	promptLabel.Text = "Do you want to teleport to level " .. tostring(teleportLevel) .. "?"
	TeleportGui.Enabled = true
end)

yesButton.MouseButton1Click:Connect(function()
	if currentDestination then
		TeleportResponse:FireServer("Yes", currentDestination)
	end
	TeleportGui.Enabled = false
	currentDestination = nil
end)

noButton.MouseButton1Click:Connect(function()
	TeleportResponse:FireServer("No")
	TeleportGui.Enabled = false
	currentDestination = nil
end)

uis.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Return then
		if currentDestination then
			TeleportResponse:FireServer("Yes", currentDestination)
		end
		TeleportGui.Enabled = false
		currentDestination = nil
	end
end)

uis.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape then
		TeleportResponse:FireServer("No")
		TeleportGui.Enabled = false
		currentDestination = nil
	end
end)