--[[
	PlayerScriptsLoader - This script requires and instantiates the PlayerModule singleton
	
	2018 PlayerScripts Update - AllYourBlox	
	2020 Modifications - EgoMoose
--]]

local MIN_Y = math.rad(-80)
local MAX_Y = math.rad(80)
local ZERO = Vector3.new(0, 0, 0)
local IDENTITYCF = CFrame.new()
local TERRAIN = game.Workspace.Terrain

local localPlayer = game:GetService("Players").LocalPlayer
local playerModule = script.Parent:WaitForChild("PlayerModule")
local cameraModule = playerModule:WaitForChild("CameraModule")
local controlModule = playerModule:WaitForChild("ControlModule")

local baseCameraModule = cameraModule:WaitForChild("BaseCamera")
local popperCamModule = cameraModule:WaitForChild("Poppercam")
local utilsModule = cameraModule:WaitForChild("CameraUtils")

-- Functions

local function getRotationBetween(u, v, axis)
	local dot, uxv = u:Dot(v), u:Cross(v)
	if (dot < -0.99999) then return CFrame.fromAxisAngle(axis, math.pi) end
	return CFrame.new(0, 0, 0, uxv.x, uxv.y, uxv.z, 1 + dot)
end

local function twistAngle(cf, direction)
	local axis, theta = cf:ToAxisAngle()
	local w, v = math.cos(theta/2),  math.sin(theta/2)*axis
	local proj = v:Dot(direction)*direction
	local twist = CFrame.new(0, 0, 0, proj.x, proj.y, proj.z, w)
	local nAxis, nTheta = twist:ToAxisAngle()
	return math.sign(v:Dot(direction))*nTheta
end

-- Controls mod

local Controls = require(controlModule)

function Controls:IsJumping()
	if self.activeController then
		return self.activeController:GetIsJumping() or (self.touchJumpController and self.touchJumpController:GetIsJumping())
	end
	return false
end

-- PopperCam mod

local Poppercam = require(popperCamModule)
local ZoomController = require(cameraModule:WaitForChild("ZoomController"))

function Poppercam:Update(renderDt, desiredCameraCFrame, desiredCameraFocus, cameraController)
	local rotatedFocus = desiredCameraFocus * (desiredCameraCFrame - desiredCameraCFrame.p)
	local extrapolation = self.focusExtrapolator:Step(renderDt, rotatedFocus)
	local zoom = ZoomController.Update(renderDt, rotatedFocus, extrapolation)
	return rotatedFocus*CFrame.new(0, 0, zoom), desiredCameraFocus
end

-- BaseCamera mod

local BaseCamera = require(baseCameraModule)

BaseCamera.UpCFrame = IDENTITYCF

function BaseCamera:UpdateUpCFrame(cf)
	self.UpCFrame = cf
end

function BaseCamera:CalculateNewLookCFrame(suppliedLookVector)
	local currLookVector = suppliedLookVector or self:GetCameraLookVector()
	currLookVector = self.UpCFrame:VectorToObjectSpace(currLookVector)
	
	local currPitchAngle = math.asin(currLookVector.y)
	local yTheta = math.clamp(self.rotateInput.y, -MAX_Y + currPitchAngle, -MIN_Y + currPitchAngle)
	local constrainedRotateInput = Vector2.new(self.rotateInput.x, yTheta)
	local startCFrame = CFrame.new(ZERO, currLookVector)
	local newLookCFrame = CFrame.Angles(0, -constrainedRotateInput.x, 0) * startCFrame * CFrame.Angles(-constrainedRotateInput.y,0,0)
	
	return newLookCFrame
end

-- Camera mod

local Camera = require(cameraModule)

local lastUpCFrame = IDENTITYCF

Camera.UpVector = Vector3.new(0, 1, 0)
Camera.TransitionRate = 0.15
Camera.UpCFrame = IDENTITYCF

Camera.SpinPart = TERRAIN
Camera.LastSpinPart = TERRAIN
Camera.LastSpinCFrame = TERRAIN.CFrame
Camera.SpinCFrame = IDENTITYCF

function Camera:GetUpVector(oldUpVector)
	return oldUpVector
end

function Camera:CalculateUpCFrame()
	local oldUpVector = self.UpVector
	local newUpVector = self:GetUpVector(oldUpVector)
	
	local backup = game.Workspace.CurrentCamera.CFrame.RightVector
	local transitionCF = getRotationBetween(oldUpVector, newUpVector, backup)
	local vecSlerpCF = IDENTITYCF:Lerp(transitionCF, self.TransitionRate)
	
	self.UpVector = vecSlerpCF * oldUpVector
	self.UpCFrame = vecSlerpCF * self.UpCFrame
	
	lastUpCFrame = self.UpCFrame
end

function Camera:SetSpinPart(part)
	self.SpinPart = part
end

function Camera:CalculateSpinCFrame()
	local delta = 0
	local part = self.SpinPart
	
	if (part == self.LastSpinPart) then
		local lastCF = self.LastSpinCFrame
	
		local rotation = part.CFrame - part.CFrame.p
		local prevRotation = lastCF - lastCF.p
		
		local direction = rotation:VectorToObjectSpace(self.UpVector)
		delta = twistAngle(prevRotation:ToObjectSpace(rotation), direction)
	end
	
	self.SpinCFrame = CFrame.fromEulerAnglesYXZ(0, delta, 0)
	self.LastSpinPart = part
	self.LastSpinCFrame = part.CFrame
end

function Camera:Update(dt)
	if self.activeCameraController then
		if Camera.FFlagUserCameraToggle then
			self.activeCameraController:UpdateMouseBehavior()
		end
		
		local newCameraCFrame, newCameraFocus = self.activeCameraController:Update(dt)
		self.activeCameraController:ApplyVRTransform()
		
		self:CalculateUpCFrame()
		self:CalculateSpinCFrame()
		self.activeCameraController:UpdateUpCFrame(self.UpCFrame)
		
		-- undo shift-lock offset

		local lockOffset = Vector3.new(0, 0, 0)
		if (self.activeMouseLockController and self.activeMouseLockController:GetIsMouseLocked()) then
			lockOffset = self.activeMouseLockController:GetMouseLockOffset()
		end
		
		local offset = newCameraFocus:ToObjectSpace(newCameraCFrame)
		local camRotation = self.UpCFrame * self.SpinCFrame * offset
		newCameraFocus = newCameraFocus - newCameraCFrame:VectorToWorldSpace(lockOffset) + camRotation:VectorToWorldSpace(lockOffset)
		newCameraCFrame = newCameraFocus * camRotation
		
		--local offset = newCameraFocus:Inverse() * newCameraCFrame
		--newCameraCFrame = newCameraFocus * self.UpCFrame * offset
		
		if (self.activeCameraController.lastCameraTransform) then
			self.activeCameraController.lastCameraTransform = newCameraCFrame
			self.activeCameraController.lastCameraFocus = newCameraFocus
		end
		
		if self.activeOcclusionModule then
			newCameraCFrame, newCameraFocus = self.activeOcclusionModule:Update(dt, newCameraCFrame, newCameraFocus)
		end

		game.Workspace.CurrentCamera.CFrame = newCameraCFrame
		game.Workspace.CurrentCamera.Focus = newCameraFocus

		if self.activeTransparencyController then
			self.activeTransparencyController:Update()
		end
	end
end

function Camera:IsFirstPerson()
	if self.activeCameraController then
		return self.activeCameraController:InFirstPerson()
	end
	return false
end

function Camera:IsMouseLocked()
	if self.activeCameraController then
		return self.activeCameraController:GetIsMouseLocked()
	end
	return false
end

function Camera:IsToggleMode()
	if self.activeCameraController then
		return self.activeCameraController.isCameraToggle
	end
	return false
end

function Camera:IsCamRelative()
	return self:IsMouseLocked() or self:IsFirstPerson()
	--return self:IsToggleMode(), self:IsMouseLocked(), self:IsFirstPerson()
end

--

local Utils = require(utilsModule)

function Utils.GetAngleBetweenXZVectors(v1, v2)
	local upCFrame = lastUpCFrame -- this is kind of lame, but it works
	v1 = upCFrame:VectorToObjectSpace(v1)
	v2 = upCFrame:VectorToObjectSpace(v2)
	return math.atan2(v2.X*v1.Z-v2.Z*v1.X, v2.X*v1.X+v2.Z*v1.Z)
end

--

require(playerModule)
script:WaitForChild("Loaded").Value = true