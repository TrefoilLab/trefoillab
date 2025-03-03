local LENGTH = #"Animation"
local properties = require(script:WaitForChild("Properties"))

return function(humanoid, animate)
	local desc = humanoid:GetAppliedDescription()
	
	if (humanoid.RigType == Enum.HumanoidRigType.R6) then
		return
	end
	
	for prop, _ in next, properties.Animation do
		if (desc[prop] > 0) then
			local lookFor = prop:sub(1, #prop - LENGTH):lower()
			animate:WaitForChild(lookFor)
		end
	end
end