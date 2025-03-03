local AnimationReplicator = {}
AnimationReplicator.__index = AnimationReplicator

function AnimationReplicator.new(character)
	local self = setmetatable({}, AnimationReplicator)
	
	self.Animate = character:WaitForChild("Animate")
	self.RepHumanoid = self.Animate:WaitForChild("RepHumanoid")
	self.Loaded = self.Animate:WaitForChild("Loaded")
	
	if (not self.Loaded.Value) then
		self.Loaded.Changed:Wait()
	end
	
	return self
end

function AnimationReplicator:SetRepHumanoid(humanoid)
	self.RepHumanoid.Value = humanoid
end

return AnimationReplicator