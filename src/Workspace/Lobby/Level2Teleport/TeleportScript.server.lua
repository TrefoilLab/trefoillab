-- Can be placed in any teleport part.

local teleportPart = script.Parent
local destination = teleportPart:GetAttribute("TeleportDestination")
local teleportLevel = teleportPart:GetAttribute("TeleportLevel")

if not destination or not teleportLevel then
	warn("Attributes 'TeleportDestination' and 'TeleportLevel' must be set on the teleport part.")
	return
end

local TeleportPrompt = game.ReplicatedStorage:WaitForChild("TeleportPrompt")
local TeleportResponse = game.ReplicatedStorage:WaitForChild("TeleportResponse")

-- A debounce table to ensure we don’t spam prompts per player
local touchedPlayers = {}

teleportPart.Touched:Connect(function(hit)
	local character = hit.Parent
	if character and character:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(character)
		if player and not touchedPlayers[player] then
			touchedPlayers[player] = true
			-- Fire a prompt to the client with the destination and level info.
			TeleportPrompt:FireClient(player, destination, teleportLevel)
		end
	end
end)

TeleportResponse.OnServerEvent:Connect(function(player, response, respDestination)
	-- Check if this script is handling a prompt for this player.
	if not touchedPlayers[player] then
		return
	end

	if response == "Yes" then
		if player and player.Character then
			player.Character:MoveTo(destination)
		end
	end

	-- Allow future prompts for this player.
	touchedPlayers[player] = nil
end)
