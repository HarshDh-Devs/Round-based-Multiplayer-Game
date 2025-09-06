local ActivePlayersInGame = require(game:GetService("ReplicatedStorage").ActivePlayersInGame)
local PlayersOnPlatform = require(game:GetService("ReplicatedStorage").PlayersOnPlatform)
local DiedPlayers = require(game.ReplicatedStorage:WaitForChild("DiedPlayers"))

local DataStoreService = game:GetService("DataStoreService") -- Access DataStoreService
local RevivesDataStore = DataStoreService:GetOrderedDataStore("Revive1")

local ReviveEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ReviveEvent")
local ReviveEventB = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ReviveEventB")
local TransitionEvent = game.ReplicatedStorage.Events:WaitForChild("TransitionEvent")

local Players = game:GetService("Players")

local respawnEffect = game:GetService("ServerStorage"):WaitForChild("RespawnEffect")

-------------------------------------------
local platform = game.Workspace:WaitForChild("SpinningPlatform"):WaitForChild("MovingPlatform")
local platformBarrier = game.Workspace.SpinningPlatform:WaitForChild("PlatformBarrier")
local restrictedRadius = 13 -- Radius of the restricted central area --13
local platformRadius =  25-- Radius of the entire platform -- 25
local platformHeight = 5 -- Height of the platform --5
local spawnHeightOffset = 2 -- Height above the platform to spawn players --2
local function getRandomSpawnPosition()
	local maxRetries = 100
	local retries = 0

	while retries < maxRetries do
		-- Generate a random angle and radius
		local angle = math.random() * 2 * math.pi
		local radius = math.sqrt(math.random()) * platformRadius -- Uniform distribution

		-- Check if the point is outside the restricted radius
		if radius > restrictedRadius then
			-- Calculate x and z positions
			local x = radius * math.cos(angle)
			local z = radius * math.sin(angle)
			local y = platform.Position.Y + platformHeight / 2 + spawnHeightOffset

			return Vector3.new(x, y, z)
		end
		retries = retries + 1
	end

	-- If it doesn't succeed in maxRetries, return a fallback position
	return platform.Position + Vector3.new(0, platformHeight / 2, 0)
end

local function teleportPlayersOnPlatform(player)
	-- Use a separate table to avoid modifying the PlayersOnPlatform table during iteration
	local playersToAddToPlatform = {}

	--for _, player in pairs(game.Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				player.PlayerGui.Invite.Enabled = false -- DISABLE Invite Gui
			player.PlayerGui.SpectateGui.Enabled = false
			player.PlayerGui.Revive.Enabled = false

				-- Check if player is already in PlayersOnPlatform table before adding them
				if not table.find(PlayersOnPlatform, player) then
					table.insert(playersToAddToPlatform, player)
				end
				if not table.find(ActivePlayersInGame.Players, player) then
					table.insert(ActivePlayersInGame.Players, player)
				end

				-- Get a random spawn position
				local spawnPosition = getRandomSpawnPosition()
				humanoidRootPart.CFrame = CFrame.new(spawnPosition)
			end
		end
	--end

	-- After the loop is done, add players to PlayersOnPlatform
	for _, player in ipairs(playersToAddToPlatform) do
		table.insert(PlayersOnPlatform, player)
	end
end
-------------------------------------------
local function savePlayerRevives(player)
	local revives = player:FindFirstChild("Revives")
	if revives then
		local success, err = pcall(function()
			RevivesDataStore:SetAsync(player.UserId, revives.Value)
		end)	
	end
end
-------------------------------------------

ReviveEventB.OnServerEvent:Connect(function(player)
	local success, err = pcall(function()
		TransitionEvent:FireClient(player)
		wait(1.5)
		teleportPlayersOnPlatform(player)
		local revive = player:FindFirstChild("Revives")
		if revive then
			revive.Value = revive.Value - 1
			savePlayerRevives(player)
		end
			
		
		local cA = respawnEffect.A:Clone()
		local cB = respawnEffect.B:Clone()
		cA.Parent = player.Character:FindFirstChild("HumanoidRootPart")	
		cB.Parent = player.Character:FindFirstChild("HumanoidRootPart")	
		wait(2)
		cA.Enabled = false
		cB.Enabled = false
		wait(1)
		cA:Destroy()
		cB:Destroy()
		
		
	end)
end)

---------------------
local winConnections = {}

local function onWinIncrease(player)
	local wins = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Wins")

	if wins then
		-- Disconnect previous connection if it exists
		if winConnections[player] then
			winConnections[player]:Disconnect()
		end

		local prevWins = wins.Value

		winConnections[player] = wins.Changed:Connect(function(newWins)
			if newWins % 5 == 0 and newWins > prevWins then
				print(player.Name .. " reached " .. newWins .. " wins! Function triggered.")
				player:FindFirstChild("Revives").Value += 2
			end
			prevWins = newWins
		end)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		onWinIncrease(player)
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	-- Clean up connection when player leaves
	if winConnections[player] then
		winConnections[player]:Disconnect()
		winConnections[player] = nil
	end
end)

