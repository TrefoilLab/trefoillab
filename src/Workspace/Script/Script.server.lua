
-- print("Hello!")
-- print("Hello world!")
trefoil = {
	{
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 2, 1, 1, 1},
		{1, 1, 1, 1, 1, 2, 1, 1, 1},
		{1, 1, 1, 1, 1, 2, 1, 1, 1},
		{1, 1, 2, 1, 1, 1, 1, 1, 1},
		{1, 1, 2, 1, 2, 2, 2, 1, 1},
		{1, 1, 2, 1, 1, 1, 2, 1, 1},
		{1, 1, 1, 1, 1, 1, 2, 1, 1}
	},
	{
		{1, 1, 1, 1, 1, 2, 1, 1, 1},
		{1, 1, 1, 1, 1, 2, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 2, 1, 1, 2, 1, 1, 1},
		{1, 1, 2, 1, 1, 2, 1, 1, 1},
		{1, 1, 1, 2, 2, 1, 2, 2, 1},
		{1, 1, 2, 1, 1, 1, 1, 1, 1},
		{1, 1, 2, 1, 1, 1, 1, 1, 1}
	},
	{
		{2, 2, 2, 2, 2, 2, 1, 1, 1},
		{2, 1, 1, 1, 1, 1, 1, 1, 1},
		{2, 1, 2, 2, 2, 2, 2, 2, 1},
		{2, 1, 2, 1, 1, 1, 1, 2, 1},
		{2, 1, 1, 1, 1, 2, 1, 2, 1},
		{2, 2, 2, 2, 1, 2, 1, 2, 1},
		{1, 1, 1, 1, 1, 2, 1, 1, 1},
		{1, 1, 2, 2, 2, 2, 1, 1, 1}
	},
	{
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1}
	},
}

aa = {{},{},{},{}}
bb = {{},{},{},{}}


--a = {
--	{
--		{},{},{},{},{},{},{},{},{},{},{}
--	},{
--		{},{},{},{},{},	{},{},{},{},{},{}
--	},{
--		{},{},{},{},{},	{},{},{},{},{},{}
--	},{
--		{},{},{},{},{},	{},{},{},{},{},{}
--	},{
--		{},{},{},{},{},	{},{},{},{},{},{}
--	},{
--		{},{},{},{},{},	{},{},{},{},{},{}
--	},{
--		{},{},{},{},{},	{},{},{},{},{},{}
--	},{
--		{},{},{},{},{},	{},{},{},{},{},{}
--	},{
--		{},{},{},{},{},	{},{},{},{},{},{}
--	},{
--		{},{},{},{},{},	{},{},{},{},{},{}
--	}
--}    -- new array

a = {
	{
		{},{},{},{},{},{},{},{},{}
	},{
		{},{},{},{},{},{},{},{},{}
	},{
		{},{},{},{},{},{},{},{},{}
	},{
		{},{},{},{},{},{},{},{},{}
	}
}
--for i=1, 3 do
for i=1,4 do
	for j=1,8 do
		for k=1,9 do
			-- r = math.random(1,2) -- either 1 or 2
			r= trefoil[i][j][k]
			if (r==1)then
				print("Adding another trefoil part.")
				a[i][j][k]=Instance.new("Part",workspace)
				a[i][j][k].Size = Vector3.new(5,5,5)
				a[i][j][k].Position = Vector3.new(5*j,5*i-5, 5*k)			
				a[i][j][k].BrickColor = BrickColor.new("Olive")
				a[i][j][k].Anchored = true	
				a[i][j][k].CastShadow = false		
			end 
		end
	end
end
myPart = Instance.new("Part",workspace)
myPart.Position = Vector3.new(5,0,5)

mortenPart = Instance.new("Part",workspace)
mortenPart.Position = Vector3.new(4,0,5)

pPart = Instance.new("Part",workspace)
pPart.Position = Vector3.new(3,0,5)

dPart = Instance.new("Pants",workspace)
dPart.Name = "Buttwhere"
blackrobots = {
--	game.Workspace.Robots.BlackRobot1,
--	game.Workspace.Robots.BlackRobot2,
--	game.Workspace.Robots.BlackRobot3,
--	game.Workspace.Robots.BlackRobot4,
--	game.Workspace.Robots.BlackRobot5,
--	game.Workspace.Robots.BlackRobot6,
--	game.Workspace.Robots.BlackRobot7,
--	game.Workspace.Robots.BlackRobot8,
--	game.Workspace.Robots.BlackRobot9,
--	game.Workspace.Robots.BlackRobotA,
--	game.Workspace.Robots.BlackRobotB,
	game.Workspace.Robots.BlackRobotC
}

local numRobots = 0
for _ in pairs(blackrobots) do numRobots = numRobots + 1 end
print("The number of robots is",numRobots)
--numRobots = blackrobots.length

-- Variables for the zombie and its humanoid
for i=1,numRobots do
	local zombie = blackrobots[i]
	local humanoid = zombie.Humanoid
 
	humanoid.WalkSpeed = 12
	
	
	-- Variables for the point(s) the zombie should move between
	local pointA = game.Workspace.GoToLocation
	 
	-- Move the zombie to the primary part of the green flag model
	humanoid:MoveTo(pointA.Position)
end


fibs = { 1, 1 }                                -- Initial values for fibs[1] and fibs[2].
setmetatable(fibs, {
  __index = function(values, n)                --[[__index is a function predefined by Lua, 
                                                   it is called if key "n" does not exist.]]
    values[n] = values[n - 1] + values[n - 2]  -- Calculate and memorize fibs[n].
    return values[n]
  end
})


fibArray = {{0},{0,1}}
setmetatable(fibArray, {
	__index = function(values, n)
		x = values[n-1]
		y = values[n-2]
z = {}
n = 0
for _,v in ipairs(x) do n=n+1; z[n]=v end
for _,v in ipairs(y) do n=n+1; z[n]=v end
--				values[n] = values[n-1]+values[n-2]
		return z
	end })


	print(
		fibArray[1][1]
		)
	print(
		fibArray[2][1],
		fibArray[2][2]
		)
	print(
		fibArray[3][1],
		fibArray[3][2],
		fibArray[3][3]
		)
		print(
		fibArray[4][1],
		fibArray[4][2],
		fibArray[4][3],
		fibArray[4][4],
		fibArray[4][5]
		)

for i=1,100 do
	isFib = false
	for j=1,10 do
		r= fibs[j]
		if i==r then
			isFib = true
		end 
	end
	if not isFib then
		aa[i]=Instance.new("Part",workspace)
		aa[i].Size = Vector3.new(5,5,5)
		aa[i].Position = Vector3.new(0,0, -10-5*i)			
		aa[i].BrickColor = BrickColor.new("Yellow")
		aa[i].Anchored = true			
	end 
	end

for i=1,200 do
	if fibArray[23][i] == 0 then
		bb[i] = Instance.new("Part",workspace)
		bb[i].Size = Vector3.new(4,4,4)
		bb[i].Position = Vector3.new(5,0,-10-5*i)
		bb[i].BrickColor = BrickColor.new("Artichoke")
		bb[i].Anchored = true
	end
end

calc = {
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
}

calc2 = {
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
}
calc3 = {
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},	{},{},{},{},{},
}
print(("So..."))
-- Need the gamepass for this to happen:
--for x=1,200 do
--	for y=1,200 do
--		xx = x/5
--		yy = y/5
--		z = math.abs(5*math.sin(xx)*math.sin(yy))-5
--		calc[x][y] = Instance.new("Part",workspace)
--		calc[x][y].Size = Vector3.new(1,1,1)
--		calc[x][y].Position = Vector3.new(35+x,z,-10-y)
--		calc[x][y].BrickColor = BrickColor.new("Royal purple")
--		calc[x][y].Anchored = true
--	end
--end

for x=1,100 do
	for y=1,100 do
		xx = x/15
		yy = y/15
		--z = math.abs(5*math.sin(xx)*yy)-5
		z = math.abs(5*math.random(0,1)*yy)-5
		calc2[x][y] = Instance.new("Part",workspace)
		calc2[x][y].Size = Vector3.new(1,1,1)
		calc2[x][y].Position = Vector3.new(235+x,z,-10-y)
		calc2[x][y].BrickColor = BrickColor.new("Carnation pink")
		calc2[x][y].Anchored = true
	end
end

for x=1,200 do
	for y=1,200 do
		xx = x/15
		yy = y/15
		z = math.abs(5*math.sin(xx)*math.cos(yy))-5
		calc3[x][y] = Instance.new("Part",workspace)
		calc3[x][y].Size = Vector3.new(1,1,1)
		calc3[x][y].Position = Vector3.new(335+x,z,-10-y)
		calc3[x][y].BrickColor = BrickColor.new("Eggplant")
		calc3[x][y].Anchored = true
	end
end


print("...hmmm")
for i=1,numRobots do
	local zombie = blackrobots[i]
	local humanoid = zombie.Humanoid
 
	humanoid.WalkSpeed = 12

	-- Variables for the point(s) the zombie should move between
	local pointA = game.Workspace.GoToLocation
	 
	-- Move the zombie to the primary part of the green flag model
	humanoid:MoveTo(pointA.Position)
end

s = math.random(1,2)
if s==1 then
	workspace.Sign.Text.SurfaceGui.TextLabel.Text = "01101"
end
if s==2 then
	workspace.Sign.Text.SurfaceGui.TextLabel.Text = "01010"
end
