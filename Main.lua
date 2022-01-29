-- [[ Configuration ]] --
if (not game:IsLoaded()) then
  game.Loaded:Wait();
end

_G.LengthOfFlinging = 30 -- How long to fling and spam (make longer for more flinging)
_G.SpamMessages = { -- What you want to spam
	'',
    ''
};
_G.FollowingMessage = ' || ' -- The 'tail' of the message | ex: add klioxide#5320 (|| JOIN .gg/4WJk4pPstp) [quotes are Following messages]
_G.botnames = { -- All of the bots spamming users case sensitive
	"grimsbloodissocool",
    "7cqw"
};
-----------------------------------------

local InjuryBot = Instance.new("ScreenGui")
InjuryBot.Name = "BotScript"
InjuryBot.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
InjuryBot.ResetOnSpawn = false

function Flinger()
	local script = Instance.new('LocalScript', InjuryBot)
	
	wait(5)
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	
	-- // Variables
	local LP = game.Players.LocalPlayer
	local LPChar = game.Players.LocalPlayer.Character
	
	
	-- // Services
	local InjurtVU = game:GetService("VirtualUser")
	local RunService = game:GetService("RunService")
	local HTTPService = game:GetService("HttpService")
	local TPService = game:GetService("TeleportService")
	
	local function ServerHop()
        local queue_on_teleport = syn and syn.queue_on_teleport or queue_on_teleport
            if (queue_on_teleport) then
                queue_on_teleport("loadstring(game.HttpGet(game, \"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()");
            end
		local AvailableServers = HTTPService:JSONDecode(
			game:HttpGet("https://games.roblox.com/v1/games/417267366/servers/Public?sortOrder=Asc&limit=100")
		)
	
		while wait() do
			local RandomServer = AvailableServers.data[math.random(#AvailableServers.data)]
			if RandomServer.playing < RandomServer.maxPlayers - 2 and RandomServer.playing > 7 and RandomServer.id ~= game.JobId then
				TPService:TeleportToPlaceInstance(game.PlaceId, RandomServer.id)
			end
		end
	end
	
	local function hop()
		ServerHop()
		while wait(15) do
			pcall(ServerHop)
		end
	end

	for i, v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do -- exploit function
        v:Disable()
    end
	
	local function Chat(msg)
		game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
	end
	
	local success, fail = pcall(
		function()
			for index, player in ipairs(game.Players:GetPlayers()) do
				if player ~= LP then
					if table.find(_G.botnames, player.Name) then
						hop()
						wait(200)
					end
				end
			end
	
			for i = 1, 3 do
				for a, plr in ipairs(game.Players:GetPlayers()) do
					if plr ~= LP then
						if table.find(_G.botnames, plr.Name) then
							hop()
							wait(200)
						end
					end
				end
				wait(1)
			end
			
			LPChar.Humanoid.Died:Connect(function()
				print("Character Died, hopping servers")
				wait(3)
				hop()
			end)
	
			spawn(function()
				while wait(0.5) do
					pcall(function()
						for index, plr in pairs(game.Players:GetPlayers()) do
							if plr ~= LP and plr.Character:FindFirstChild("HumanoidRootPart") and LPChar and LPChar:FindFirstChild("HumanoidRootPart") then
								local HRP = LP.Character:FindFirstChild("HumanoidRootPart")
								local OldCF = HRP.CFrame
								local OriginalVel = HRP.Velocity

								local Flinging = nil
								local Returning = nil
								local nclipping = nil
								local function Follow()
									local function a()
										HRP.CFrame = plr.Character.HumanoidRootPart.CFrame 
									end
									Flinging = RunService.RenderStepped:Connect(a)
								end
								local function Return()
									for i,v in next, (LP.Character:GetChildren()) do
										if v:IsA('BasePart') then
											v.CanCollide = true
											v.Massless = false
										end
									end
									local function a()
										HRP.CFrame = OldCF
										HRP.Velocity = OriginalVel
									end
									Returning = RunService.Stepped:Connect(a)
								end
								local function noclipping()
									local function a()
										for i,v in next, LP.Character:GetChildren() do
											if v:IsA('BasePart') then
												v.CanCollide = false
											end
										end
									end
									nclipping = RunService.Stepped:Connect(a)
								end
								Follow()
								if plr.Backpack:FindFirstChildOfClass("Tool") then
									plr.Backpack:FindFirstChildOfClass("Tool").Parent = plr.Character
								end
								local BV = Instance.new('BodyAngularVelocity')
								BV.Name = 'NMFling'
								BV.AngularVelocity = Vector3.new(9e2, 80000, -9e2)
								BV.MaxTorque = Vector3.new(1, 0.1, 1) * math.huge
								BV.P = 9e9
								BV.Parent = LP.Character.HumanoidRootPart

								for i,v in next, (LP.Character:GetChildren()) do
									if v:IsA('BasePart') then
										v.CanCollide = false
										v.Massless = true
										v.Velocity = Vector3.new(0, 0, 0)
									end
								end
								noclipping()

								wait(2)
								BV:Destroy()
								Flinging:Disconnect()
								nclipping:Disconnect()
								wait(1)
								Return()
								wait(3)
								HRP.Anchored = true
								Returning:Disconnect()
								HRP.Anchored = false
								HRP.CFrame = OldCF
								HRP.Velocity = OriginalVel
							end
						end
					end)	
				end
			end)
		end
	)
	wait(_G.LengthOfFlinging)
	print("Server Hopping")
	hop()
	
	if not success then
		print("Error: " ..fail)
		hop()
	end
end
coroutine.wrap(Flinger)()
