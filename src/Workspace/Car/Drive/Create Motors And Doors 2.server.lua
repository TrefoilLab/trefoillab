--MADE BY NWSPACEK

WheelSize = 3--diameter of the wheel

--When you are editing the car, make sure that the Left, Right, and Base parts are in a 
--straight line, and in the orientation the models comes with, or they won't be where you expect
--them to be at all!

motorSpeed = 0.05 -- a typical number is 0.1 but lower is better if you get weird behavior


--don't touch below, very delicate
car = script.Parent.Parent

Base = car:FindFirstChild("Base")
Left = car:FindFirstChild("Left")
Right = car:FindFirstChild("Right")

function MakeDoor(hinge,door,hingeOffset,doorOffset)
	local doorMotor = Instance.new("Motor",car)
	doorMotor.Name = hinge.Name.."Motor"
	doorMotor.Part0 = door
	doorMotor.Part1 = hinge
	doorMotor.C0 = doorOffset
	doorMotor.C1 = hingeOffset
	doorMotor.MaxVelocity = 0.05
	door.CanCollide = true
	local doorDebounce = false
	door.Touched:connect(function(it)
		if not doorDebounce and it.Parent and it.Name == "HumanoidRootPart" and game:GetService("Players"):GetPlayerFromCharacter(it.Parent) then
			doorDebounce = true
			door.CanCollide = false
			doorMotor.DesiredAngle =  math.pi/3
			wait(1.5)
			doorMotor.DesiredAngle = 0
			wait(0.5)
			door.CanCollide = true
			doorDebounce = false
		end
	end)
end
function MakeWeldDoor(hinge,door)
	local doorMotor = Instance.new("Motor6D",car)
	doorMotor.Name = hinge.Name.."Motor"
	doorMotor.Part0 = door
	doorMotor.Part1 = hinge
	doorMotor.C1 = hinge.CFrame:inverse()*door.CFrame
	door.CanCollide = false
end

function GetCFrame(object)--we'll get a CFrame value out of a CFrameValue or a StringValue formatted like a CFrame
	if object:IsA("CFrameValue") then--if someone is using a CFrame value then we'll just pull the value directly
		return object.Value
	elseif object:IsA("StringValue") then--added functionality for this because I dislike interfacing with CFrame values
		local cframe = nil
		pcall(function()--using pcall because i'm lazy
			cframe = CFrame.new(object.Value:match("(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+)"))
			--if you print your CFrame and paste it into the string value, this will find that out and use it properly
		end)
		return cframe
	end
end

for _,h in pairs (car:GetChildren()) do
	if h:IsA("Motor6D") then--make sure we start with a blank slate
		h:Destroy()
	end
end

for _,i in pairs (car:GetChildren()) do
	if i:IsA("BasePart") and i.Name:find("DoorHinge") then-- found a door with regex!
		local DoorID = i.Name:match("DoorHinge(.*)")--haha regex is fun
		local MatchingDoor = car:FindFirstChild("Door"..DoorID)--can we use our regex powers to find a matching door?
		if MatchingDoor then-- yay we found one!
			local DoorCFrameValue = MatchingDoor:FindFirstChild("DoorCFrame")
			local HingeCFrameValue = MatchingDoor:FindFirstChild("HingeCFrame")
			if DoorCFrameValue and HingeCFrameValue then
				local doorCFrame = GetCFrame(DoorCFrameValue)
				local hingeCFrame = GetCFrame(HingeCFrameValue)
				if doorCFrame and hingeCFrame then
					MakeDoor(i,MatchingDoor,hingeCFrame,doorCFrame)
				else
					MakeWeldDoor(i,MatchingDoor)
				end
			else
				MakeWeldDoor(i,MatchingDoor)
			end
		end
	end
end

if Base then
	if Left then
		leftMotor = Instance.new("Motor6D", car)
		leftMotor.Name = "LeftMotor"
		leftMotor.Part0 = Left
		leftMotor.Part1 = Base
		leftMotor.C0 = CFrame.new(-WheelSize/2-Left.Size.x/2,0,0)*CFrame.Angles(math.pi/2,0,-math.pi/2)
		leftMotor.C1 = CFrame.new(Base.Size.x/2+Left.Size.x+WheelSize/2,0,0)*CFrame.Angles(math.pi/2,0,math.pi/2)
		leftMotor.MaxVelocity = motorSpeed
	end
	if Right then
		rightMotor = Instance.new("Motor6D", car)
		rightMotor.Name = "RightMotor"
		rightMotor.Part0 = Right
		rightMotor.Part1 = Base
		rightMotor.C0 = CFrame.new(-WheelSize/2-Right.Size.x/2,0,0)*CFrame.Angles(math.pi/2,0,math.pi/2)
		rightMotor.C1 = CFrame.new(-Base.Size.x/2-Right.Size.x-WheelSize/2,0,0)*CFrame.Angles(math.pi/2,0,math.pi/2)
		rightMotor.MaxVelocity = motorSpeed
	end
end