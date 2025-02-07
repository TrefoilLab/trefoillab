local textBox = script.Parent
 
local function complexity(myString)
	if myString == "01101" then
		return "3"
	end
	if myString == "01010" then
		return "2"
	end
return "0"
end

local function onFocusLost(enterPressed)
	if enterPressed then
		print("The player typed: " .. textBox.Text)
		-- Color the text box according to the typed color
		local brickColor = BrickColor.new(textBox.Text)
		textBox.BackgroundColor3 = brickColor.Color
		if complexity(
			workspace.Sign.Text.SurfaceGui.TextLabel.Text
		) == textBox.Text then
			workspace.Sign.Text.SurfaceGui.TextLabel.Text = "yes"
			end
	end
end
textBox.FocusLost:Connect(onFocusLost)