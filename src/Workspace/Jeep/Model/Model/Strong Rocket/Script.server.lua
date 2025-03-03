local isOn = true

function on()
	isOn = true
	script.Parent.BrickColor = BrickColor.new(23)
	script.Parent.BodyThrust.force = Vector3.new(-1000, 0, 0)
end

function off()
	isOn = false
	script.Parent.BrickColor = BrickColor.new(26)
	script.Parent.BodyThrust.force = Vector3.new(0, 0, 0)
end

function onClicked()
	
	if isOn == true then off() else on() end

end

script.Parent.ClickDetector.MouseClick:connect(onClicked)

on()