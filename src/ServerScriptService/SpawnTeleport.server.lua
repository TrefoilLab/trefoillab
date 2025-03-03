local TeleportToSpawn = game.ReplicatedStorage:WaitForChild("TeleportToSpawn")

-- Ensure destination is a valid Vector3 position
local spawnPart = workspace.Lobby.e:GetAttribute("Spawn")

TeleportToSpawn.OnServerEvent:Connect(function(player)
	if player and player.Character then
		player.Character:MoveTo(spawnPart)
	else
		warn("Player or character missing for teleport!")
	end
end)
