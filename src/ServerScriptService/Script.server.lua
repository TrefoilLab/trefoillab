local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local passID = 253521016 -- 0000000  -- Change this to your Pass ID

local function onPlayerAdded(player)
	local hasPass = false

	-- Check if the player already owns the Pass
	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, passID)
	end)

	-- If there's an error, issue a warning and exit the function
	if not success then
		warn("Error while checking if player has pass: " .. tostring(message))
		return
	end
	
	calc = {
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
		{},{},{},{},{},
	}
--hasPass = false
	
	if hasPass then
		print(player.Name .. " owns the Pass with ID " .. passID)
		-- Assign this player the ability or bonus related to the Pass
		for x=1,2000 do
			for y=1,2000 do
				xx = x/5
				yy = y/5
				z = math.abs(5*math.sin(xx)*math.sin(yy))-5
				calc[x][y] = Instance.new("Part",workspace)
				calc[x][y].Size = Vector3.new(1,1,1)
				calc[x][y].Position = Vector3.new(35+x,z,-10-y)
				calc[x][y].BrickColor = BrickColor.new("Eggplant")
				calc[x][y].Anchored = true
			end
		end
	end
	if not hasPass then
		print("You do not have the gamepass!!")
		for x=1,100 do
			for y=1,100 do
				xx = x/5
				yy = y/5
				z = math.abs(5*math.sin(xx)*math.sin(yy))-5
				calc[x][y] = Instance.new("Part",workspace)
				calc[x][y].Size = Vector3.new(1,1,1)
				calc[x][y].Position = Vector3.new(35+x,z,-10-y)
				calc[x][y].BrickColor = BrickColor.new("Eggplant")
				calc[x][y].Anchored = true
			end
		end
	end
end

-- Connect "PlayerAdded" events to the function
Players.PlayerAdded:Connect(onPlayerAdded)