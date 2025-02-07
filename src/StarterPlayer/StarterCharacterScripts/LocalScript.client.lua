-- Grav Controller Test
-- https://www.youtube.com/watch?v=j-4cdhQxFJA

local PLAYERS = game:GetService("Players")
local RUNSERVICE = game:GetService("RunService")

local GravityController = require(game:GetService("ReplicatedStorage"):WaitForChild("GravityController"))
local Controller = GravityController.new(PLAYERS.LocalPlayer)

local PI2 = math.pi*2
local ZERO = Vector3.new(0, 0, 0)

local LOWER_RADIUS_OFFSET = 3 
local NUM_DOWN_RAYS = 24
local ODD_DOWN_RAY_START_RADIUS = 3	
local EVEN_DOWN_RAY_START_RADIUS = 2
local ODD_DOWN_RAY_END_RADIUS = 1.66666
local EVEN_DOWN_RAY_END_RADIUS = 1

local NUM_FEELER_RAYS = 9
local FEELER_LENGTH = 2
local FEELER_START_OFFSET = 2
local FEELER_RADIUS = 3.5
local FEELER_APEX_OFFSET = 1
local FEELER_WEIGHTING = 8

function GetGravityUp(self, oldGravityUp)
	local ignoreList = {}
	for i, player in next, PLAYERS:GetPlayers() do
		ignoreList[i] = player.Character
	end
	
	-- get the normal
	
	local hrpCF = self.HRP.CFrame
	local isR15 = (self.Humanoid.RigType == Enum.HumanoidRigType.R15)
	
	local origin = isR15 and hrpCF.p or hrpCF.p + 0.35*oldGravityUp
	local radialVector = math.abs(hrpCF.LookVector:Dot(oldGravityUp)) < 0.999 and hrpCF.LookVector:Cross(oldGravityUp) or hrpCF.RightVector:Cross(oldGravityUp)
	
	local centerRayLength = 25
	local centerRay = Ray.new(origin, -centerRayLength * oldGravityUp)
	local centerHit, centerHitPoint, centerHitNormal = workspace:FindPartOnRayWithIgnoreList(centerRay, ignoreList)
	
	local downHitCount = 0
	local totalHitCount = 0
	local centerRayHitCount = 0
	local evenRayHitCount = 0
	local oddRayHitCount = 0
	
	local mainDownNormal = ZERO
	if (centerHit) then
		mainDownNormal = centerHitNormal
		centerRayHitCount = 0
	end
	
	local downRaySum = ZERO
	for i = 1, NUM_DOWN_RAYS do
		local dtheta = PI2 * ((i-1)/NUM_DOWN_RAYS)
		
		local angleWeight = 0.25 + 0.75 * math.abs(math.cos(dtheta))
		local isEvenRay = (i%2 == 0)
		local startRadius = isEvenRay and EVEN_DOWN_RAY_START_RADIUS or ODD_DOWN_RAY_START_RADIUS	
		local endRadius = isEvenRay and EVEN_DOWN_RAY_END_RADIUS or ODD_DOWN_RAY_END_RADIUS
		local downRayLength = centerRayLength
		
		local offset = CFrame.fromAxisAngle(oldGravityUp, dtheta) * radialVector
		local dir = (LOWER_RADIUS_OFFSET * -oldGravityUp + (endRadius - startRadius) * offset)
		local ray = Ray.new(origin + startRadius * offset, downRayLength * dir.unit)
		local hit, hitPoint, hitNormal = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

		if (hit) then
			downRaySum = downRaySum + angleWeight * hitNormal
			downHitCount = downHitCount + 1
			if isEvenRay then
				evenRayHitCount = evenRayHitCount + 1					
			else
				oddRayHitCount = oddRayHitCount + 1
			end
		end
	end
	
	local feelerHitCount = 0	
	local feelerNormalSum = ZERO
	
	for i = 1, NUM_FEELER_RAYS do
		local dtheta = 2 * math.pi * ((i-1)/NUM_FEELER_RAYS)
		local angleWeight =  0.25 + 0.75 * math.abs(math.cos(dtheta))	
		local offset = CFrame.fromAxisAngle(oldGravityUp, dtheta) * radialVector
		local dir = (FEELER_RADIUS * offset + LOWER_RADIUS_OFFSET * -oldGravityUp).unit
		local feelerOrigin = origin - FEELER_APEX_OFFSET * -oldGravityUp + FEELER_START_OFFSET * dir
		local ray = Ray.new(feelerOrigin, FEELER_LENGTH * dir)
		local hit, hitPoint, hitNormal = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
		
		if (hit) then
			feelerNormalSum = feelerNormalSum + FEELER_WEIGHTING * angleWeight * hitNormal --* hitDistSqInv
			feelerHitCount = feelerHitCount + 1
		end
	end
	
	if (centerRayHitCount + downHitCount + feelerHitCount > 0) then
		local normalSum = mainDownNormal + downRaySum + feelerNormalSum
		if (normalSum ~= ZERO) then
			return normalSum.unit
		end
	end
	
	return oldGravityUp
end

Controller.GetGravityUp = GetGravityUp

RUNSERVICE.Heartbeat:Connect(function(dt)
	local height = Controller:GetFallHeight()
	if height < -50 then
		Controller:ResetGravity(Vector3.new(0, 1, 0))
	end
end)