local DataStoreService = game:GetService("DataStoreService") -- Access DataStoreService
local winsDataStore = DataStoreService:GetOrderedDataStore("test1") -- Create or access the "PlayerWins" DataStore
local RevivesDataStore = DataStoreService:GetOrderedDataStore("Revive1")

-- Function to load player data
local function loadPlayerWins(player)
	local success, data = pcall(function()
		return winsDataStore:GetAsync(player.UserId) -- Retrieve data using the player's UserId
	end)

	if success then
		if data then		
			-- Create a leaderstats folder for tracking wins
			local leaderstats = Instance.new("Folder", player)
			leaderstats.Name = "leaderstats"

			local wins = Instance.new("IntValue", leaderstats)
			wins.Name = "Wins"
			wins.Value = data -- Set the retrieved number of wins			
		else		
			-- Create default data for new players
			local leaderstats = Instance.new("Folder", player)
			leaderstats.Name = "leaderstats"

			local wins = Instance.new("IntValue", leaderstats)
			wins.Name = "Wins"
			wins.Value = 0 -- Default wins
			
		end
	else
		warn("Failed to load wins for " .. player.Name)
	end
	-------------------
	local success, revData = pcall(function()
		return RevivesDataStore:GetAsync(player.UserId) -- Retrieve data using the player's UserId
	end)

	if success then
		if revData then		
			local revives = Instance.new("IntValue", player)
			revives.Name = "Revives"
			revives.Value = revData
		else
			local revives = Instance.new("IntValue", player)
			revives.Name = "Revives"
			revives.Value = 3 -- Default Revives
		end
	else
		warn("Failed to load Revievs for " .. player.Name)
	end
end

-- Function to save player data
local function savePlayerWins(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local wins = leaderstats:FindFirstChild("Wins")
		local revives = player:FindFirstChild("Revives")
		if wins then
			local success, err = pcall(function()
				winsDataStore:SetAsync(player.UserId, wins.Value) -- Save the player's current wins
				RevivesDataStore:SetAsync(player.UserId, revives.Value)
			end)	
		end
	end
	
	
	
end

-- Handle when a player joins
game.Players.PlayerAdded:Connect(function(player)
	loadPlayerWins(player)
end)

-- Handle when a player leaves
game.Players.PlayerRemoving:Connect(function(player)
	savePlayerWins(player)
end)
