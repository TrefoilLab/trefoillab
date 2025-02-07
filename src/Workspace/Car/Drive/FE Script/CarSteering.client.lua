--MADE BY NWSPACEK
wait(1)-- give it time to adjust to the scary and new environment of Backpack
SeatValue = script:WaitForChild("Seat")-- orient ourselves to the car we are sitting in
if SeatValue:IsA("ObjectValue") and SeatValue.Value and SeatValue.Value:IsA("VehicleSeat") then
	seat = SeatValue.Value
	car = seat.Parent
	if seat:FindFirstChild("RocketPropulsion") then
		seat.RocketPropulsion:Fire()--THIS DOESNT WORK MEGA QQ
	end
	local RemoteControlled = car:FindFirstChild("ControlByRemote")
	while seat:FindFirstChild("SeatWeld") and RemoteControlled do--what this loop does is continue running until the 
		wait()--statement between the "while" and "do" is not true. 
		if not RemoteControlled:IsA("VehicleSeat") then --think you can make ControlByRemote a different part and make it break?
			break-- NOPE!!!!! Still won't break!
		end-- (well, I suppose so because it says break over there)
		RemoteControlled.Throttle = seat.Throttle-- but the important bit is no red text
		if car:FindFirstChild("LeftMotor") then
			car.LeftMotor.DesiredAngle = seat.Steer*math.rad(40-RemoteControlled.Velocity.magnitude/4)
		end
		if car:FindFirstChild("RightMotor") then
			car.RightMotor.DesiredAngle = seat.Steer*math.rad(40-RemoteControlled.Velocity.magnitude/4)
		end
		if car:FindFirstChild("Configuration") then
			if seat.Throttle == 1 and car.Configuration:FindFirstChild("Forwards Speed") then
				RemoteControlled.MaxSpeed = car.Configuration["Forwards Speed"].Value
			elseif seat.Throttle == 0 then
				RemoteControlled.MaxSpeed = 0
			elseif seat.Throttle == -1 and car.Configuration:FindFirstChild("Reverse Speed") then
				RemoteControlled.MaxSpeed = car.Configuration["Reverse Speed"].Value
			end
		end
	end
	-- the interesting thing about loops is they stop everything below them from running
	-- until the loop stops. When the loop stops because the player is no longer sitting
	-- the below code will run:
	if seat:FindFirstChild("RocketPropulsion") then
		seat.RocketPropulsion:Abort()--I'LL JUST LEAVE IT IN IN CASE IT EVER DOES
	end
end
script:Destroy()-- momma always said to clean up after yourself