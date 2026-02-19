local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local espOn = false
local espColor = Color3.fromRGB(255,0,0)
local aimbotEnabled = false
local aiming = false
local ignoreFriends = false
local wallcheck = false
local target = nil
local flying = false

local espObjects = {}
local SWAP_RADIUS = 500

local function isFriend(plr)
	return localPlayer:IsFriendsWith(plr.UserId)
end

UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	
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

RunService.RenderStepped:Connect(function()
	if not aimbotEnabled or not aiming then return end
	
	target = getClosestTarget()
	
	if not target then return end
	
	local head = target:FindFirstChild("Head")
	if not head then return end
	
	-- Check if target head is visible (wall check)
	if wallcheck and not isTargetVisible(head) then
		return
	end
	
	camera.CFrame =
		CFrame.new(
			camera.CFrame.Position,
			head.Position
		)

end)

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
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

local Window = Library:CreateWindow{
    Title = `Universal FPS`,
    SubTitle = "Version 1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
}
local Tabs = {
    Aimbot = Window:CreateTab{
        Title = "Aimbot",
        Icon = "target"
    },
    Visual = Window:CreateTab{
        Title = "Visuals",
        Icon = "scan-eye"
    }
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}
local esptoggle = Tabs.Visual:CreateToggle("esptoggle", {
    Title = "ESP",
    Default = false,
    Callback = function(Value)
        espOn = Value
        if espOn then
            for _,plr in pairs(Players:GetPlayers()) do
                onPlayer(plr)
            end
        else
            clearESP()
        end
    end
})
local espcolorpicker = Tabs.Visual:CreateColorpicker("espcolorpicker", {
    Title = "ESP Color",
    Default = Color3.fromRGB(255,0,0)
})

espcolorpicker:OnChanged(function()
    espColor = espcolorpicker.Value
end)

local aimbottoggle = Tabs.Aimbot:CreateToggle("Aimbottoggle", {
    Title = "Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
    end
})

local friendchecktoggle = Tabs.Aimbot:CreateToggle("friendcheck", {
    Title = "Friend Check",
    Default = false,
    Callback = function(Value)
        ignoreFriends = Value
    end
})

SaveManager:SetFolder("CheeseOnHacks/UniversalFPS")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

