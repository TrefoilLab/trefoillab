local rail = script.Parent
local slideSpeed = 50 -- Adjust for smooth sliding
local verticalTolerance = 5 -- Increased vertical tolerance to account for animation
local horizontalTolerance = 2 -- Horizontal tolerance for rail position check
local momentumRetention = 0.8 -- Percentage of momentum retained after sliding (0.8 = 80%)
local jumpBoost = 0.8 -- Multiplier for jump strength when jumping off the rail
local momentumDuration = 1 -- Duration in seconds for how long the momentum lasts
local jumpCooldown = 0.5 -- Cooldown in seconds after jumping before allowing re-detection

local activeSliders = {} -- Tracks players currently sliding
local recentJumpers = {} -- Tracks players who recently jumped

-- Animation ID for the sliding animation
local animationId = "rbxassetid://105156542990985"

-- Function to check if player is on the rail
local function isPlayerOnRail(rootPart, rail)
	local railCFrame = rail.CFrame
	local railSize = rail.Size
	local playerPos = railCFrame:pointToObjectSpace(rootPart.Position)

	return math.abs(playerPos.X) <= railSize.X/2 + horizontalTolerance
		and math.abs(playerPos.Y) <= railSize.Y/2 + verticalTolerance
		and math.abs(playerPos.Z) <= railSize.Z/2 + horizontalTolerance
end

-- Function to stop sliding and preserve momentum
local function stopSliding(player, humanoid, rootPart, bodyGyro, linearVelocity, attachment, animator, isJumping)
	if not player or not activeSliders[player] then return end

	print("Stopping slide for", player.Name)

	activeSliders[player] = nil
	if bodyGyro then bodyGyro:Destroy() end
	if attachment then attachment:Destroy() end

	if animator then
		local slideTrack = animator:GetPlayingAnimationTracks()[1]
		if slideTrack then slideTrack:Stop() end
	end

	-- Preserve momentum
	local currentVelocity = linearVelocity.VectorVelocity
	linearVelocity:Destroy()

	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		humanoid.AutoRotate = true
		humanoid.PlatformStand = false

		-- Get player's input direction
		local moveDirection = humanoid.MoveDirection

		-- If there's input, blend it with the current velocity
		if moveDirection.Magnitude > 0 then
			currentVelocity = (currentVelocity + moveDirection * currentVelocity.Magnitude).Unit * currentVelocity.Magnitude
		end

		-- Apply momentum and jump boost if jumping
		local retainedMomentum = currentVelocity * momentumRetention
		if isJumping then
			local jumpVelocity = Vector3.new(0, humanoid.JumpPower * jumpBoost, 0)
			rootPart.Velocity = retainedMomentum + jumpVelocity

			-- Set recent jumper cooldown
			recentJumpers[player] = true
			delay(jumpCooldown, function()
				recentJumpers[player] = nil
			end)
		else
			rootPart.Velocity = retainedMomentum
		end

		-- Create a BodyVelocity to maintain momentum
		local bodyVelocity = Instance.new("BodyVelocity", rootPart)
		bodyVelocity.Velocity = retainedMomentum
		bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge) -- Allow vertical movement

		-- Remove the BodyVelocity after the momentum duration
		game:GetService("Debris"):AddItem(bodyVelocity, momentumDuration)
	end

	player:SetAttribute("IsSliding", false)
end

-- Function to start sliding
local function startSliding(player, humanoid, rootPart)
	if activeSliders[player] or recentJumpers[player] then return end

	print("Starting slide for", player.Name)
	activeSliders[player] = true

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 50
	humanoid.AutoRotate = false
	humanoid.PlatformStand = true

	local railRight = rail.CFrame.RightVector
	local railUp = rail.CFrame.UpVector
	local railLook = rail.CFrame.LookVector
	local newCFrame = CFrame.fromMatrix(rootPart.Position, railRight, railUp, railLook)

	local bodyGyro = Instance.new("BodyGyro", rootPart)
	bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
	bodyGyro.D = 100
	bodyGyro.P = 3000
	bodyGyro.CFrame = newCFrame

	local attachment = Instance.new("Attachment", rootPart)
	local linearVelocity = Instance.new("LinearVelocity", rootPart)
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = math.huge
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = railRight * slideSpeed

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local slideTrack = animator:LoadAnimation(animation)
	slideTrack:Play()

	player:SetAttribute("IsSliding", true)

	local heartbeatConnection
	heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
		if not rootPart or not rootPart:IsDescendantOf(workspace) or not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then
			heartbeatConnection:Disconnect()
			stopSliding(player, humanoid, rootPart, bodyGyro, linearVelocity, attachment, animator, false)
			return
		end

		if not isPlayerOnRail(rootPart, rail) then
			heartbeatConnection:Disconnect()
			stopSliding(player, humanoid, rootPart, bodyGyro, linearVelocity, attachment, animator, false)
		elseif humanoid.Jump then
			heartbeatConnection:Disconnect()
			stopSliding(player, humanoid, rootPart, bodyGyro, linearVelocity, attachment, animator, true)
		end
	end)
end

-- Use Touched event for immediate response
rail.Touched:Connect(function(hit)
	local character = hit.Parent
	local humanoid = character and character:FindFirstChild("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local player = game.Players:GetPlayerFromCharacter(character)

	if humanoid and rootPart and player and isPlayerOnRail(rootPart, rail) and not activeSliders[player] and not recentJumpers[player] then
		startSliding(player, humanoid, rootPart)
	end
end)