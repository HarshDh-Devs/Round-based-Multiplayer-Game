local Remote = game.ReplicatedStorage.Ragdoll
local M  = require(game:GetService("ServerScriptService"):WaitForChild("Ragdoll"):WaitForChild("Manager"))
local prompt = game:GetService("ServerStorage"):WaitForChild("PushProximityPrompt")
local ActivePlayersInGame = require(game:GetService("ReplicatedStorage").ActivePlayersInGame)
local DiedPlayers = require(game.ReplicatedStorage:WaitForChild("DiedPlayers"))
local Players = game:GetService("Players")
local PlayerManager = require(game.ReplicatedStorage:WaitForChild("PlayerManager"))

local ReviveEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("ReviveEvent")

local GameIsRunning =  game.ReplicatedStorage:WaitForChild("Values"):WaitForChild("GameIsRunning")
--GAMEPASS--
local MarketplaceService = game:GetService("MarketplaceService")
local Tool = game.ServerStorage:WaitForChild("BananaPeel")
local GamePassID = 1083560651


---BADGES--
local badgeService = game:GetService("BadgeService")
local WelcomeBadge = 4029335443209616
local FirstWin = 948181899050277
local fiveWins = 784578287678398
local TenWins = 1736631988320810
local FiftyWins = 936381660155827
local HundredWins = 1293090714564250

local function givebadgefunction(Plr, WinsRequired, badgeID)
	local wins = Plr:FindFirstChild("leaderstats") and Plr.leaderstats:FindFirstChild("Wins")
	if wins.Value >= WinsRequired then
		local success, hasBadge = pcall(function()
			return badgeService:UserHasBadgeAsync(Plr.UserId, badgeID)
		end)
		if success and not hasBadge then
			badgeService:AwardBadge(Plr.UserId, badgeID)
		end
	end
end
-----------
game.Players.PlayerAdded:Connect(function(Plr)
	Plr.CharacterAdded:Connect(function(Char)
		
		local RespawnedPlr = table.find(DiedPlayers, Plr)
		if RespawnedPlr and GameIsRunning.Value == true and Plr:FindFirstChild("Revives").Value > 0 then
			wait(2)
			ReviveEvent:FireClient(Plr)
		end
		
		
		wait(1)
		local Hum : Humanoid = Char:WaitForChild("Humanoid")
		local Root : BasePart = Char:WaitForChild("HumanoidRootPart")
		local newprompt = prompt:Clone()
		newprompt.Parent=Root
		
		
		
		--------------
		if Plr.Name == game.ReplicatedStorage.Values.TopPlayerName.Value then
			local title = game:GetService("ServerStorage"):FindFirstChild("Title"):Clone()
			title.Parent = Char.Head
		end
		if Plr.Name == game.ReplicatedStorage.Values.SecondTopPlayerName.Value then
			local title = game:GetService("ServerStorage"):FindFirstChild("TitleSecond"):Clone()
			title.Parent = Char.Head
		end
		if Plr.Name == game.ReplicatedStorage.Values.ThirdTopPlayerName.Value then
			local title = game:GetService("ServerStorage"):FindFirstChild("TitleThird"):Clone()
			title.Parent = Char.Head
		end
		--------------
		
		
		task.wait(1)
		------++++++++++++++++++
		local success, hasPass = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(Plr.UserId, GamePassID)
		end)

		if success and hasPass then
			local backpack = Plr:FindFirstChild("Backpack")
			if backpack and Tool then
				local clonedTool = Tool:Clone()
				clonedTool.Parent = backpack
			end
		end	
		------++++++++++++++
		
		--Char.Head.Size = Vector3.new(1, 1, 1)
		Hum.BreakJointsOnDeath = false
		Hum.RequiresNeck = false
	    
		local Attach = Instance.new("Attachment",Root)
        Attach.Name = "ForceAttachment"
		Hum.Died:Connect(function()
			M.Ragdoll(Char)
			Root:SetNetworkOwner(Plr)
			game.ReplicatedStorage.RagdollForce:FireClient(Plr)
		end)
	end)
	
	------------BADGES SCRIPTS----------BADGES SCRIPTS----------BADGES SCRIPTS---------START
	------------WELCOME BADGE-----------
	local success, hasBadge = pcall(function()
		return badgeService:UserHasBadgeAsync(Plr.UserId, WelcomeBadge)
	end)

	if success then
		if not hasBadge then
			badgeService:AwardBadge(Plr.UserId, WelcomeBadge)
		end
	end
	---------------------------------
	-------------WINS BADGES--------------------
	local leaderstats = Plr:WaitForChild("leaderstats")
	local wins = leaderstats:WaitForChild("Wins")
	
	if not leaderstats or not wins then
		warn("⚠️ Missing leaderstats or Wins for", Plr.Name)
		return
	end

	local function checkBadge()
		givebadgefunction(Plr, 1, FirstWin)
		givebadgefunction(Plr, 5, fiveWins)
		givebadgefunction(Plr, 10, TenWins)
		givebadgefunction(Plr, 50, FiftyWins)
		givebadgefunction(Plr, 100, HundredWins)
		
	end
	checkBadge()
	wins.Changed:Connect(checkBadge)---- Listen for changes in Wins
	------------BADGES SCRIPTS----------BADGES SCRIPTS----------BADGES SCRIPTS---------END
	
	
end)

game.ReplicatedStorage.OnDeath.OnServerEvent:Connect(function(Plr,Char)
	local Hum : Humanoid = Char:FindFirstChild("Humanoid")
	local findPlayer = table.find(ActivePlayersInGame.Players, Plr)
	--if findPlayer then
	--	table.remove(ActivePlayersInGame.Players, findPlayer)
	--else
	if Hum.Health <= 0 then return end
	if Plr.Character ~= Char then return end

		Hum.Health = 0
end)




Players.PlayerRemoving:Connect(function(player)
	task.defer(PlayerManager.RemovePlayerFromGame, player)
end)
