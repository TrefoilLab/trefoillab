for _,i in pairs (script:GetChildren()) do
	if i:IsA("VehicleSeat") then
		i.Torque = 0
		i.MaxSpeed = 0
		i.Changed:connect(function()
			i.Torque = 0
			i.MaxSpeed = 0
		end)
	end
end