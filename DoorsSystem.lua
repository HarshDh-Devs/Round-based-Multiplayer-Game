local OpenDoor = game:GetService("ReplicatedStorage").Events.OpenDoor
local CloseDoor = game:GetService("ReplicatedStorage").Events.CloseDoor
local NoOfDoorsEvent = game:GetService("ReplicatedStorage").Events.NoOfDoorsEvent

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(
	0.20, -- Duration of the movement (in seconds)
	Enum.EasingStyle.Exponential, -- Easing style
	Enum.EasingDirection.InOut, -- Easing direction
	0, -- Number of times to repeat (-1 for infinite)
	false -- Reverses the tween after each completion
)

local folder = game.Workspace.Rooms.Rooms 
local allDoors = folder:GetChildren()
local selectedDoors = {}

-- Track the connection to prevent duplicate listeners
local noOfDoorsConnection
if noOfDoorsConnection then
	noOfDoorsConnection:Disconnect()
end
-- New connection
noOfDoorsConnection = NoOfDoorsEvent.Event:Connect(function(num)
	-- Clear the selectedDoors list to avoid duplicates across events
	selectedDoors = {}
	for _ = 1, math.min(num, #allDoors) do
		local randomPart

		repeat
			local randomIndex = math.random(1, #allDoors)
			randomPart = allDoors[randomIndex]
		until not table.find(selectedDoors, randomPart)

		-- Add the unique part to the list
		table.insert(selectedDoors, randomPart)
	end

end)

-- Open doors
local doorData = {} -- Table to store door-specific data

OpenDoor.Event:Connect(function()
	for _, room in ipairs(selectedDoors) do
		local door = room.ChangeColor.Door
		local isDoorOpen = room.DoorButton.ProximityPrompt.isDoorOpen
		local positionA = door.CFrame -- Initial CFrame
		local positionB = positionA * CFrame.new(-4.9, 0, 0) -- Target position
		
		local DoorSound = door.Sound
		
		local tweenMoveToB = TweenService:Create(door, tweenInfo, {CFrame = positionB})
		local tweenMoveToA = TweenService:Create(door, tweenInfo, {CFrame = positionA})

		-- Store the tweens and door data
		table.insert(doorData, {door = door, tweenToB = tweenMoveToB, tweenToA = tweenMoveToA, isDoorOpen = isDoorOpen, DoorSound = DoorSound})
		if isDoorOpen.Value == false then
			tweenMoveToB:Play() -- Open the door
			isDoorOpen.Value = true
		end
		
	end
end)

CloseDoor.Event:Connect(function()
	for _, data in ipairs(doorData) do
		if data.isDoorOpen.Value == true then
			data.DoorSound:Play()
			data.tweenToA:Play() -- Close the door
			data.isDoorOpen.Value = false 
		end
	
	end
end)
