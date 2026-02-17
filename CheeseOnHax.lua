local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- SETTINGS (DEFINED FIRST)
--------------------------------------------------

local espOn = false
local aimbotEnabled = false
local aiming = false
local ignoreFriends = false
local target = nil

local espObjects = {}
local SWAP_RADIUS = 500

local DefaultSettings = {
	AutoLoadEnabled = false,
	TeleportLoadEnabled = false,
	DisableScriptLoader = false,
	SelectedVersion = nil,
	SelectedTab = "UniversalFPS",
	ThemeColor = "Darker",
	ScriptToggles = {
		Rivals_Classic = false,
		Rivals_Modern = false,
		Rivals_SkinChanger = false,
		Arsenal = false,
		Universal = false,
		BigPaintball2 = false,
		AimbotFFA = false,
		Bladeball = false,
		GunGroundsFFA = false,
		CombatWarriors = false,
		Fisch = false,
		MurderMystery2 = false,
		FleeTheFacility = false,
		Forsaken = false,
		BlueLock_Rivals = false,
		GrowAGarden = false,
		Brookhaven = false,
		MurderersVsSheriffsDuels = false,
        NightsInTheForest = false,
        Fling2Climb = false,
	}
}

--------------------------------------------------
-- ESP SYSTEM
--------------------------------------------------

local function createESP(character)
	if espObjects[character] then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local head = character:FindFirstChild("Head")
	if not humanoid or not head then return end
	
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255,0,0)
	highlight.FillTransparency = 0.5
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = character
	
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,200,0,50)
	billboard.StudsOffset = Vector3.new(0,2.5,0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1,0,1,0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1,1,1)
	text.TextStrokeTransparency = 0
	text.Font = Enum.Font.SourceSansBold
	text.TextScaled = true
	text.Parent = billboard
	

	while humanoid.Parent and espOn do
		text.Text =
			character.Name ..
			"\nHP: " ..
			math.floor(humanoid.Health)
		task.wait(0.1)
	end

	
	espObjects[character] = {
		highlight = highlight,
		gui = billboard
	}
end

local function clearESP()
	for _, obj in pairs(espObjects) do
		if obj.highlight then obj.highlight:Destroy() end
		if obj.gui then obj.gui:Destroy() end
	end
	espObjects = {}
end

--------------------------------------------------
-- FRIEND CHECK
--------------------------------------------------

local function isFriend(plr)
	return localPlayer:IsFriendsWith(plr.UserId)
end

--------------------------------------------------
-- TARGET FUNCTION
--------------------------------------------------

local function getClosestTarget()
	local closest = nil
	local bestScore = math.huge
	
	local camPos = camera.CFrame.Position
	local camLook = camera.CFrame.LookVector
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= localPlayer and plr.Character then
			
			if ignoreFriends and isFriend(plr) then
				continue
			end
			
			local humanoid =
				plr.Character:FindFirstChildOfClass("Humanoid")
			local head =
				plr.Character:FindFirstChild("Head")
			
			if humanoid and head and humanoid.Health > 0 then
				
				local distance =
					(head.Position - camPos).Magnitude
				
				if distance <= SWAP_RADIUS then
					
					local direction =
						(head.Position - camPos).Unit
					
					local angle =
						math.acos(math.min(1, camLook:Dot(direction)))
					
					local score = angle + (distance / 1000)
					
					if score < bestScore then
						bestScore = score
						closest = plr.Character
					end
				end
			end
		end
	end
	
	return closest
end

--------------------------------------------------
-- INPUT
--------------------------------------------------

UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	
	if input.KeyCode == Enum.KeyCode.F1 then
		espOn = not espOn
		
		if espOn then
			for _,plr in pairs(Players:GetPlayers()) do
				if plr ~= localPlayer and plr.Character then
					createESP(plr.Character)
				end
			end
		else
			clearESP()
		end
	end
	
	if input.KeyCode == Enum.KeyCode.F2 then
		aimbotEnabled = not aimbotEnabled
		target = nil
	end
	
	if input.KeyCode == Enum.KeyCode.F3 then
		ignoreFriends = not ignoreFriends
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = true
		target = nil
	end
end)

UIS.InputEnded:Connect(function(input,gp)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = false
		target = nil
	end
end)

--------------------------------------------------
-- AIMBOT LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()
	if not aimbotEnabled or not aiming then return end
	
	target = getClosestTarget()
	
	if not target then return end
	
	local head = target:FindFirstChild("Head")
	if not head then return end
	
	camera.CFrame =
		CFrame.new(
			camera.CFrame.Position,
			head.Position
		)
end)

--------------------------------------------------
-- RESPAWN ESP
--------------------------------------------------

local function onPlayer(plr)
	if plr == localPlayer then return end
	
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		if not char or not char.Parent then return end
		if espOn then
			createESP(char)
		end
	end)
end

for _,plr in pairs(Players:GetPlayers()) do
	onPlayer(plr)
end

Players.PlayerAdded:Connect(onPlayer)

--------------------------------------------------
-- GUI (LOADED IN BACKGROUND)
--------------------------------------------------

task.spawn(function()

	local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
	local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
	local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

	local Window = Library:CreateWindow({
		Title = "Cheese on hax",
		SubTitle = "Script Loader",
		TabWidth = 160,
		Size = UDim2.fromOffset(580, 460),
		Acrylic = true,
		Theme = "Darker",
		MinSize = Vector2.new(470, 380),
		MinimizeKey = Enum.KeyCode.RightControl
	})

	local Tabs = {
		Info = Window:CreateTab({
			Title = "Info",
			Icon = "info"
		}),
		UniversalFPS = Window:CreateTab({
			Title = "Universal FPS",
			Icon = "target"
		}),
		othershit = Window:CreateTab({
			Title = "other shit",
			Icon = "settings"
		}),
		PlayerTab = Window:CreateTab({
			Title = "Player",
			Icon = "circle-user"
        }),
		solunastuff = Window:CreateTab({
			Title = "Soluna",
			Icon = "radar"
        })
    }
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--paragraphs and shit
----------------------------------------------------------------------------------------------------------------
	Tabs.UniversalFPS:CreateParagraph("Universal", {
		Title = "Universal FPS",
		Content = "Universal shit for most FPS games (rivals included)"
	})
	Tabs.PlayerTab:CreateParagraph("Player", {
		Title = "Player",
		Content = "here is all the shit that does player shit like walkspeed, go fish"
	})
	Tabs.Info:CreateParagraph("Info", {
		Title = "I piss thunder and shit lightning",
		Content = "HUGE credits to the soluna dev team and master oogway\nSoluna : https://github.com/EndOverdosing\nMaster Oogway : https://github.com/ActualMasterOogway"
	})
	Tabs.solunastuff:CreateParagraph("Soluna", {
		Title = "Here are a bunch of scripts made by soluna",
		Content = " "
	})
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

	Tabs.solunastuff:CreateButton({
		Title = "Load 99 nights in the forest",
		Description = "Key (case sensitive) = EndOverdosing",
		Callback = function()
			loadstring(game:HttpGet(('https://raw.githubusercontent.com/EndOverdosing/Soluna-API/refs/heads/main/99-Nights-in-the-Forest.lua'),true))()
		end
	})
	Tabs.solunastuff:CreateButton({
		Title = "Rivals Modern",
		Description = "no key",
		Callback = function()
			loadstring(game:HttpGet(('https://raw.githubusercontent.com/EndOverdosing/Soluna-API/refs/heads/main/rivals-modern.lua'),true))()
		end
	})

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

	local flytoggle = Tabs.PlayerTab:CreateToggle("FlyToggle", {
		Title = "Fly",
		Default = false,
		Callback = function(Value)
			--some fly logic here and yep
		end
	})

	local flyslider = Tabs.PlayerTab:CreateSlider("Slider", {
	    Title = "Fly Speed",
	    Description = "self explanitory",
	    Default = 2,
	    Min = 1,
	    Max = 20,
	    Rounding = 1,
	    Callback = function(Value)
	        print("Slider was changed:", Value)
	    end
	})

	local aimbottoggle = Tabs.UniversalFPS:CreateToggle("AimbotToggle", {
		Title = "Aimbot",
		Default = false,
		Callback = function(Value)
			aimbotEnabled = Value
		end
	})

	local esptoggle = Tabs.UniversalFPS:CreateToggle("ESPToggle", {
		Title = "ESP",
		Default = false,
		Callback = function(Value)
			espOn = Value
			if espOn then
				for _,plr in pairs(Players:GetPlayers()) do
					if plr ~= localPlayer and plr.Character then
						createESP(plr.Character)
					end
				end
			else
				clearESP()
			end
		end
	})

	local friendcheck = Tabs.UniversalFPS:CreateToggle("FriendCheck", {
		Title = "Friend Check",
		Default = false,
		Callback = function(Value)
			ignoreFriends = Value
		end
	})

	Tabs.othershit:CreateButton({
		Title = "Load Infinite Yield",
		Description = "Load it loads infinite yield. what more could there be",
		Callback = function()
			loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
		end
	})
end)

--coolio


