local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Doctor Hub",
   Icon = 0, 
   LoadingTitle = "Doctor Hub",
   LoadingSubtitle = "by Dr.Ghalb",
   ShowText = "Rayfield", 
   Theme = "Default", 

   ToggleUIKeybind = "K", 

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, 

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, 
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, 
      Invite = "noinvitelink", 
      RememberJoins = true 
   },

   KeySystem = true, 
   KeySettings = {
      Title = "Key",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", 
      FileName = "Key", 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"nigga"} 
   }
})

local PlayerTab = Window:CreateTab("Player", 4483362458) 
local TelTab = Window:CreateTab("Teleport", 4483362458) 

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local connections = {}
local HIGHLIGHT_NAME = "PlayerHighlight"

local FILL_COLOR = Color3.fromRGB(255, 0, 0)   
local OUTLINE_COLOR = Color3.fromRGB(255, 255, 255)

local function addHighlightToCharacter(character)
	if not character or not character.Parent then return end
	if character:FindFirstChild(HIGHLIGHT_NAME) then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = HIGHLIGHT_NAME
	highlight.Parent = character
	highlight.FillColor = FILL_COLOR
	highlight.OutlineColor = OUTLINE_COLOR
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function removeHighlightFromCharacter(character)
	local h = character and character:FindFirstChild(HIGHLIGHT_NAME)
	if h then h:Destroy() end
end

local function removeAllHighlights()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			removeHighlightFromCharacter(player.Character)
		end
	end
end

local function setupPlayer(player)
	if player == LocalPlayer then return end

	if player.Character then
		addHighlightToCharacter(player.Character)
	end

	local charAdded = player.CharacterAdded:Connect(addHighlightToCharacter)
	local charRemoving = player.CharacterRemoving:Connect(removeHighlightFromCharacter)

	table.insert(connections, charAdded)
	table.insert(connections, charRemoving)
end

local function disconnectAll()
	for _, conn in ipairs(connections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	connections = {}
end

local Toggle = PlayerTab:CreateToggle({
	Name = "Esp",
	CurrentValue = false,
	Flag = "Toggle1",
	Callback = function(Value)
		if Value then
			for _, player in ipairs(Players:GetPlayers()) do
				setupPlayer(player)
			end
			local playerAdded = Players.PlayerAdded:Connect(setupPlayer)
			table.insert(connections, playerAdded)
		else
			removeAllHighlights()
			disconnectAll()
		end
	end,
})

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local player = Players.LocalPlayer
local speed = 50
local bodyGyro
local bodyVelocity
local flying = false

local function setFlyState(state)
	flying = state
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	if flying then
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.P = 9e4
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = root.CFrame
		bodyGyro.Parent = root

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVelocity.Parent = root
	else
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	end
end

RS.RenderStepped:Connect(function()
	if flying then
		local character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then return end
		local root = character.HumanoidRootPart
		local camera = workspace.CurrentCamera

		bodyGyro.CFrame = camera.CFrame
		local moveDir = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end

		bodyVelocity.Velocity = moveDir * speed
	end
end)

local Toggle = PlayerTab:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Flag = "FlyToggle",
	Callback = function(Value)
		setFlyState(Value)
	end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local noclipEnabled = false

local function setNoClip(character)
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
end

local function onCharacterAdded(character)
    setNoClip(character)
    character.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") then
            desc.CanCollide = not noclipEnabled
        end
    end)
end

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

RunService.RenderStepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        setNoClip(LocalPlayer.Character)
    end
end)

local Toggle = PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        noclipEnabled = Value
        if LocalPlayer.Character then
            setNoClip(LocalPlayer.Character)
        end
    end,
})

local Slider = PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 10,
   Flag = "Slider1",
   Callback = function(Value)
   game.Players.LocalPlayer.character.Humanoid.WalkSpeed = Value
   end,
})

local Slider = PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 10,
   Suffix = "Jump",
   CurrentValue = 10,
   Flag = "Slider1",
   Callback = function(Value)
      local player = game.Players.LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      local humanoid = character:WaitForChild("Humanoid")

      humanoid.UseJumpPower = true
      humanoid.JumpPower = Value
   end,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Button = TelTab:CreateButton({ 
    Name = "Spawn",
    Callback = function()
        local targetPosition = Vector3.new(-733, 5, 2121)  

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
        else
            warn("HumanoidRootPart not found!")
        end
    end,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Button = TelTab:CreateButton({ 
    Name = "Bank",
    Callback = function()
        local targetPosition = Vector3.new(-620, 6, 2040)  

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
        else
            warn("HumanoidRootPart not found!")
        end
    end,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Button = TelTab:CreateButton({ 
    Name = "LebasForoshi",
    Callback = function()
        local targetPosition = Vector3.new(-645, 6, 2137)  

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
        else
            warn("HumanoidRootPart not found!")
        end
    end,
})



local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Button = TelTab:CreateButton({ 
    Name = "Amlak-Shoghl",
    Callback = function()
        
        local targetPosition = Vector3.new(-632, 6, 2195)  

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
            
        else
            warn("HumanoidRootPart پیدا نشد!")
        end
    end,
})
















--=== تنظیمات سرویس‌ها ===--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--=== نام RemoteEvent برای درخواست pickup ===--
local REMOTE_NAME = "RequestPickup"
local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME) or Instance.new("RemoteEvent", ReplicatedStorage)
remote.Name = REMOTE_NAME

--=== تنظیمات عمومی ===--
local TARGET_NAME = "P2"               -- اسم پارت‌هایی که باید بری سراغشون
local TELEPORT_OFFSET = Vector3.new(0, 3, 0)
local PICKUP_WAIT = 1.5
local TIME_BETWEEN = 0.3
local NEAR_THRESHOLD = 4

-- وضعیت روشن/خاموش بودن سیستم
local running = false

-- تابع برای جمع کردن همه Partهایی که اسمشون P2 هست
local function gatherTargets()
    local targets = {}
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") and inst.Name == TARGET_NAME then
            table.insert(targets, inst)
        end
    end
    return targets
end

-- تلپورت به سمت هر Part
local function teleportToPart(part)
    if not part or not part:IsDescendantOf(Workspace) then return false end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    hrp.CFrame = CFrame.new(part.Position + TELEPORT_OFFSET)
    return true
end

-- صبر کن تا پارت حذف بشه (یعنی برداشته شده)
local function waitForPickup(part, timeout)
    local elapsed = 0
    while elapsed < (timeout or PICKUP_WAIT) do
        if not running then return false end
        if not part.Parent then return true end
        task.wait(0.2)
        elapsed += 0.2
    end
    return false
end

-- روند اصلی برای pickup همه P2‌ها
local function runAutoPick()
    local targets = gatherTargets()
    if #targets == 0 then
        warn("هیچ پارت با نام '"..TARGET_NAME.."' پیدا نشد.")
        running = false
        return
    end

    for _, part in ipairs(targets) do
        if not running then break end
        if not part.Parent then continue end

        teleportToPart(part)
        task.wait(0.3)

        -- اگر Remote موجوده، درخواست به سرور بفرست
        if remote then
            remote:FireServer(part)
        end

        -- منتظر باش تا پارت حذف بشه
        waitForPickup(part, PICKUP_WAIT)
        task.wait(TIME_BETWEEN)
    end

    running = false
end

--=== Toggle در UI ===--
local Toggle = TelTab:CreateToggle({
    Name = "Auto Pickup P2",
    CurrentValue = false,
    Flag = "Toggle_AutoPickP2",
    Callback = function(Value)
        running = Value
        if running then
            task.spawn(runAutoPick)
        else
            print("AutoPickup متوقف شد.")
        end
    end,
})

