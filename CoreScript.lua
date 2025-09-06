--// Services & Modules
local TimeModule = require(game:GetService("ReplicatedStorage"):WaitForChild("TimeModule"))
wait(TimeModule.TopScriptLaunchingTime)

local DataStoreService = game:GetService("DataStoreService")
local winsDataStore = DataStoreService:GetOrderedDataStore("test1")

local SoundService = game:GetService("SoundService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

-- Workspace references
local platform = workspace:WaitForChild("SpinningPlatform"):WaitForChild("MovingPlatform")
local platformBarrier = workspace.SpinningPlatform:WaitForChild("PlatformBarrier")
local Rooms = workspace:WaitForChild("Rooms"):WaitForChild("Rooms")

-- Audio
local sound = SoundService:WaitForChild("Sound")
local LightOffSound = SoundService:WaitForChild("LightsOff")
local NotificationSound = SoundService:WaitForChild("NotificationSound")
local ConfettiSound = SoundService:WaitForChild("ConfettiSound")
local WinSound = SoundService:WaitForChild("WinSound")
local trumpet = SoundService:WaitForChild("Trumpet")

-- Assets
local DiedEffect = ServerStorage:WaitForChild("DiedEffect")

-- Gameplay geometry
local restrictedRadius = 13
local platformRadius = 25
local platformHeight = 5
local spawnHeightOffset = 2

-- Modules
local ActivePlayersInGame = require(ReplicatedStorage:WaitForChild("ActivePlayersInGame"))
local PlayersOnPlatform = require(ReplicatedStorage:WaitForChild("PlayersOnPlatform"))
local SafePlayersModule = require(ReplicatedStorage:WaitForChild("SafePlayersModule"))
local PlayerManager = require(ReplicatedStorage:WaitForChild("PlayerManager"))
local DiedPlayers = require(ReplicatedStorage:WaitForChild("DiedPlayers"))

-- Events
-- Centralized RemoteEvents used for server-client communication. Not all events are shown here to avoid redundancy.

-- Values
local Values = ReplicatedStorage:WaitForChild("Values")
local RoomOfValue = Values.RoomOfValue
local CanPlayerBePushed = Values:WaitForChild("CanPlayerBePushed")

--// Helpers

local function getRandomSpawnPosition()
	local maxRetries, retries = 100, 0
	while retries < maxRetries do
		local angle = math.random() * 2 * math.pi
		local radius = math.sqrt(math.random()) * platformRadius
		if radius > restrictedRadius then
			local x = radius * math.cos(angle)
			local z = radius * math.sin(angle)
			local y = platform.Position.Y + platformHeight / 2 + spawnHeightOffset
			return Vector3.new(x, y, z)
		end
		retries += 1
	end
	return platform.Position + Vector3.new(0, platformHeight / 2, 0)
end

local function teleportPlayersOnPlatform()
	local playersToAddToPlatform = {}
	for _, player in pairs(PlayersService:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				player.PlayerGui.Invite.Enabled = false
				player.PlayerGui.SpectateGui.Enabled = false
				player.PlayerGui.Revive.Enabled = false

				if not table.find(PlayersOnPlatform, player) then
					table.insert(playersToAddToPlatform, player)
				end
				if not table.find(ActivePlayersInGame.Players, player) then
					table.insert(ActivePlayersInGame.Players, player)
				end

				local spawnPosition = getRandomSpawnPosition()
				humanoidRootPart.CFrame = CFrame.new(spawnPosition)
			end
		end
	end

	for _, player in ipairs(playersToAddToPlatform) do
		table.insert(PlayersOnPlatform, player)
	end
end

-- Lobby spawn helpers
local LobbyPlatform = workspace:WaitForChild("MainSpawnPlatform")
local spawnOffset = 2
local halfSizeX, halfSizeZ = LobbyPlatform.Size.X / 2, LobbyPlatform.Size.Z / 2

local function getSpawnPosition()
	return Vector3.new(
		LobbyPlatform.Position.X + math.random(-halfSizeX, halfSizeX),
		LobbyPlatform.Position.Y + LobbyPlatform.Size.Y / 2 + spawnOffset,
		LobbyPlatform.Position.Z + math.random(-halfSizeZ, halfSizeZ)
	)
end

local function SpawnBackToLobby()
	for _, player in ipairs(PlayersService:GetPlayers()) do
		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local spawnPos = getSpawnPosition()
			local spawnCFrame = CFrame.new(spawnPos) * CFrame.Angles(0, math.rad(-90), 0)
			rootPart.CFrame = spawnCFrame
			player.PlayerGui.Invite.Enabled = true
			player.PlayerGui.SpectateGui.Enabled = true
			player.PlayerGui.Revive.Enabled = true
		end
	end
end

local function KillPlayer()
	local playersToRemove = {}
	for _, player in ipairs(ActivePlayersInGame.Players) do
		task.wait(0.03)
		if not table.find(SafePlayersModule.Players, player) then
			local character = workspace:FindFirstChild(player.Name)
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				local clone = DiedEffect:Clone()
				clone.Parent = character:FindFirstChild("HumanoidRootPart")
				wait(0.1)
				if humanoid then
					humanoid.Health = 0
					table.insert(playersToRemove, player)

					local s = SoundService.ShootSound:Clone()
					s.Name = "clonedsound"
					s.Parent = SoundService
					s:Play()
					s.Ended:Connect(function() s:Destroy() end)

					humanoid:TakeDamage(100)
				end
			end
		end
	end

	for _, deadPlayer in ipairs(playersToRemove) do
		task.defer(PlayerManager.RemovePlayerFromGame, deadPlayer)
		table.insert(DiedPlayers, deadPlayer)
	end
end

local function confetti(value)
	for _, v in pairs(workspace:WaitForChild("Confetti"):GetChildren()) do
		v.Enabled = value
	end
end

local function savePlayerWins(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local wins = leaderstats:FindFirstChild("Wins")
		if wins then
			pcall(function()
				winsDataStore:SetAsync(player.UserId, wins.Value)
			end)
		end
	end
end

local function removeFromSavePlayerModule()
	for i = #SafePlayersModule.Players, 1, -1 do
		table.remove(SafePlayersModule.Players, i)
		wait()
	end
end

local function selectRoomValue()
	local n = #ActivePlayersInGame.Players
	if n <= 0 then
		return nil
	end
	local max = math.max(2, math.min(5, n))
	if n > 2 then
		return math.random(1, max)
	else
		return math.random(1, n)
	end
end

local function teleportBackMissingPlayersToPlatform()
	local playersToTeleport = {}
	for _, player in ipairs(ActivePlayersInGame.Players) do
		task.wait(0.03)
		if not table.find(PlayersOnPlatform, player) then
			table.insert(playersToTeleport, player)
		end
	end

	for _, player in ipairs(playersToTeleport) do
		task.wait(0.03)
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local spawnPosition = getRandomSpawnPosition()
				hrp.CFrame = CFrame.new(spawnPosition)
			end
		end
	end
end

--// Core round runner: encapsulates one full round flow
local function runRound(roundLabelText, noOfDoors, isFinalRound)
	-- Start round UI/audio
	sound.SoundId = "rbxassetid://83301894631600"
	sound:Play()
	gui:Fire(3, roundLabelText)

	wait(0.5)
	NoOfDoorsEvent:Fire(noOfDoors)
	LightsA:Fire()
	StartPlatform:Fire()

	wait(math.random(TimeModule.PlatformTimeMin, TimeModule.PlatformTimeMax))
	StopsPlatformRotation:Fire()
	sound:Stop()
	LightOffSound:Play()

	-- Room selection / opening
	local aliveCount = #ActivePlayersInGame.Players
	if aliveCount <= 0 then
		gui:Fire(5, "Nobody was alive, the game ended!")
		return "ENDED"
	end

	local chosen = selectRoomValue()
	if not chosen then
		gui:Fire(5, "Nobody was alive, the game ended!")
		return "ENDED"
	end

	RoomOfValue.Value = chosen
	PushUI:Fire("unhide", ActivePlayersInGame.Players)
	NotificationSound:Play()
	NoOfPlayersGui:FireAllClients(5, "Room of " .. RoomOfValue.Value)

	CanPlayerBePushed.Value = true
	sound.SoundId = "rbxassetid://1843004759"
	sound:Play()
	OpenDoor:Fire()
	platformBarrier.CanCollide = false
	LightsE:Fire()
	timer:Fire()

	wait(TimeModule.TimeUntilDoorCloses)
	for _, room in pairs(Rooms:GetChildren()) do
		room.DoorButton.ProximityPrompt.Enabled = false
	end
	PushUI:Fire("hide", ActivePlayersInGame.Players)
	CanPlayerBePushed.Value = false

	wait(3)
	CloseDoor:Fire()
	wait(2)

	CheckIfPlayerIsSafe:Fire()
	wait(3)

	-- Remove unsafe
	KillPlayer()
	wait(3)

	sound:Stop()
	LightsC:Fire()
	OpenDoor:Fire()

	RoomOfValue.Value = 0
	for _, room in pairs(Rooms:GetChildren()) do
		room.DoorButton.ProximityPrompt.Enabled = true
	end

	-- Final round diverges only in return timing
	if isFinalRound then
		game.ReplicatedStorage.Values.GameIsRunning.Value = false
		timerB:Fire()
		wait(TimeModule.ComeBackToPlatformFINAL)
	else
		gui:Fire(10, "Return to the platform!")
		timerB:Fire()
		wait(TimeModule.ComeBackToPlatform)
	end

	wait(1)
	removeFromSavePlayerModule()
	platformBarrier.CanCollide = true
	wait(1.5)

	-- Bring stragglers to platform
	teleportBackMissingPlayersToPlatform()

	wait(0.5)
	CloseDoor:Fire()
	wait(2)

	-- Round end checks
	if #ActivePlayersInGame.Players == 1 then
		game.ReplicatedStorage.Values.GameIsRunning.Value = false
		gui:Fire(5, "Congratulations! Sole Survivor!")
		return "SOLO"
	end
	if #ActivePlayersInGame.Players <= 0 then
		gui:Fire(5, "Nobody was alive, the game ended!")
		return "ENDED"
	end

	return "OK"
end

--// Main game
local function StartMainGame()
	local function main()
		platformBarrier.CanCollide = true
		SpectateBackToPlayer:FireAllClients()
		TransitionEvent:FireAllClients()
		wait(1.5)

		teleportPlayersOnPlatform()
		wait(1)

		-- Round 1
		local r1 = runRound("ROUND 1", TimeModule.Round1NoOfDoors, false)
		if r1 ~= "OK" then return end

		-- Round 2
		local r2 = runRound("ROUND 2", TimeModule.Round2NoOfDoors, false)
		if r2 ~= "OK" then return end

		-- Round 3 (Final)
		local r3 = runRound("FINAL ROUND!", TimeModule.Round3NoOfDoors, true)
		if r3 ~= "OK" then return end
	end

	main()

	-- Post-round winner handling
	if #ActivePlayersInGame.Players == 0 then
		gui:Fire(5, "Nobody was alive, game ended!")
		return
	end

	platformBarrier.CanCollide = false
	local audioAssets = {
		"rbxassetid://1846190134",
		"rbxassetid://1843468464",
		"rbxassetid://1843468325"
	}
	local randomAudio = audioAssets[math.random(1, #audioAssets)]
	WinSound.SoundId = randomAudio
	WinSound:Play()

	confetti(true)
	ConfettiSound:Play()
	WinnersGui:FireAllClients(10, ActivePlayersInGame.Players)

	for _, v in pairs(ActivePlayersInGame.Players) do
		if v then
			v.leaderstats.Wins.Value += 1
			savePlayerWins(v)
		end
	end

	wait(3)

	for i = #ActivePlayersInGame.Players, 1, -1 do
		table.remove(ActivePlayersInGame.Players, i)
	end

	updateevent:Fire()
	removeFromSavePlayerModule()
	wait(TimeModule.CelebrationTime)

	SpawnBackToLobby()
	LightsB:Fire("LightShutsOff")
	confetti(false)
	WinSound:Stop()
	CloseDoor:Fire()
end

--// Bootstrap / Loop
trumpet:Play()
gameStartingInGui:FireAllClients(TimeModule.ServerStartingTime, " ")
wait(TimeModule.ServerStartingTime)
LightsB:Fire()

while true do
	wait(TimeModule.LightsStartTime)
	LightsD:Fire()

	for i = 0.5, 0, -0.1 do
		trumpet.Volume = i
		task.wait(0.1)
	end
	trumpet:Stop()

	wait(TimeModule.LightsStartTime)
	game.ReplicatedStorage.Values.GameIsRunning.Value = true

	local success, errorMessage = pcall(StartMainGame)
	if not success then
		warn("An error occurred in StartMainGame: " .. errorMessage)
		for i = #ActivePlayersInGame.Players, 1, -1 do
			table.remove(ActivePlayersInGame.Players, i)
		end
		SpawnBackToLobby()
		removeFromSavePlayerModule()
	else
		print("StartMainGame executed successfully.")
	end

	game.ReplicatedStorage.Values.GameIsRunning.Value = false
	LightsB:Fire("LightShutsOff")
	print("Game ENDED")
	SpectateBackToPlayer:FireAllClients()

	trumpet.Volume = 0.5
	trumpet:Play()
	gameStartingInGui:FireAllClients(TimeModule.IntermissionTime, " ")
	wait(TimeModule.IntermissionTime)

	for i = #ActivePlayersInGame.Players, 1, -1 do
		table.remove(ActivePlayersInGame.Players, i)
	end
	for i = #DiedPlayers, 1, -1 do
		table.remove(DiedPlayers, i)
	end
	removeFromSavePlayerModule()
end
