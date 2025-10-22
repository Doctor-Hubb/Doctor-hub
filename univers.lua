local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Doctor Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Doctor Hub",
   LoadingSubtitle = "by Dr.Ghalb",
   ShowText = "ِDoctorHub", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Key",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"ramz"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local PlayerTab = Window:CreateTab("🏠 Player", nil) 
local ComTab = Window:CreateTab("🔫 Combat", nil) 
local TelTab = Window:CreateTab("🏝 Teleport", nil)  

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
local Workspace = game:GetService("Workspace")

-- تابع تلپورت به یک بازیکن مشخص
local function teleportToPlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer or not targetPlayer.Character then
        warn("❌ بازیکن پیدا نشد یا کاراکتر ندارد!")
        return
    end

    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    if targetRoot and myChar and myChar:FindFirstChild("HumanoidRootPart") then
        myChar.HumanoidRootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
        print("✅ تلپورت شدی به " .. targetName)
    else
        warn("⚠️ یکی از کاراکترها ناقص است!")
    end
end

-- تابع ساخت لیست بازیکن‌ها
local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

-- Dropdown
local Dropdown = TelTab:CreateDropdown({
    Name = "Teleport To Player",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        local targetName = Options[1]
        teleportToPlayer(targetName)
    end,
})

-- به‌روزرسانی خودکار لیست وقتی کسی وارد/خارج شد
Players.PlayerAdded:Connect(function()
    Dropdown:SetOptions(getPlayerNames())
end)
Players.PlayerRemoving:Connect(function()
    Dropdown:SetOptions(getPlayerNames())
end)

































































-- === Simple Aimbot + FOV + RGB Mode + Team Check ===
do
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local mouse = LocalPlayer:GetMouse()

    -- ⚙️ تنظیمات اصلی
    local Aimbot = {
        Enabled = false,
        FOVEnabled = true,
        FOVRadius = 120,
        LockPart = "Head",
        TeamCheck = false,
        TriggerKeyName = "MouseButton2",
    }

    -- 🎯 دایره‌ی FOV
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Radius = Aimbot.FOVRadius
    circle.Color = Color3.fromRGB(255,255,255)
    circle.Thickness = 1
    circle.NumSides = 64
    circle.Filled = false
    circle.Transparency = 0.6

    -- 🌈 کنترل رنگ FOV
    local RGBEnabled = false
    local customColor = Color3.fromRGB(255, 255, 255)
    local hue = 0

    -- 🎯 پیدا کردن هدف‌ها
    local function getTargets()
        local t = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Aimbot.LockPart) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    if Aimbot.TeamCheck then
                        if p.Team ~= LocalPlayer.Team then
                            table.insert(t, p)
                        end
                    else
                        table.insert(t, p)
                    end
                end
            end
        end
        return t
    end

    local function getScreenPos(part)
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        return Vector2.new(pos.X, pos.Y), onScreen
    end

    local function findClosest()
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        local closest, dist = nil, Aimbot.FOVRadius
        for _, p in ipairs(getTargets()) do
            local part = p.Character[Aimbot.LockPart]
            local screenPos, onScreen = getScreenPos(part)
            if onScreen then
                local d = (mousePos - screenPos).Magnitude
                if d <= dist then
                    dist = d
                    closest = p
                end
            end
        end
        return closest
    end

    local function aimAt(part)
        if not part then return end
        local camPos = Camera.CFrame.Position
        Camera.CFrame = CFrame.new(camPos, part.Position)
    end

    -- 🖱 کنترل ورودی
    local aiming = false
    local function isTriggerInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Aimbot.TriggerKeyName == "MouseButton1" then return true end
        if input.UserInputType == Enum.UserInputType.MouseButton2 and Aimbot.TriggerKeyName == "MouseButton2" then return true end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            if key == Aimbot.TriggerKeyName then return true end
        end
        return false
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if isTriggerInput(input) then aiming = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if isTriggerInput(input) then aiming = false end
    end)

    -- 🔁 حلقه‌ی اصلی
    RunService.RenderStepped:Connect(function()
        if not Aimbot.Enabled then circle.Visible = false return end

        -- رنگ FOV
        if RGBEnabled then
            hue = (hue + 0.005) % 1
            circle.Color = Color3.fromHSV(hue, 1, 1)
        else
            circle.Color = customColor
        end

        -- رسم دایره
        if Aimbot.FOVEnabled then
            circle.Visible = true
            circle.Position = Vector2.new(mouse.X, mouse.Y)
            circle.Radius = Aimbot.FOVRadius
        else
            circle.Visible = false
        end

        -- هدف‌گیری
        if aiming then
            local target = findClosest()
            if target and target.Character and target.Character:FindFirstChild(Aimbot.LockPart) then
                aimAt(target.Character[Aimbot.LockPart])
            end
        end
    end)

    -- 🧩 UI Options
    ComTab:CreateToggle({
        Name = "Aimbot Enabled",
        CurrentValue = false,
        Callback = function(v) Aimbot.Enabled = v end
    })

    ComTab:CreateToggle({
        Name = "Show FOV",
        CurrentValue = true,
        Callback = function(v) Aimbot.FOVEnabled = v end
    })

    ComTab:CreateSlider({
        Name = "FOV Size",
        Range = {30, 800},
        Increment = 5,
        CurrentValue = Aimbot.FOVRadius,
        Callback = function(v) Aimbot.FOVRadius = v end
    })

    ComTab:CreateDropdown({
        Name = "Lock Part",
        Options = {"Head","UpperTorso","HumanoidRootPart"},
        CurrentOption = {Aimbot.LockPart},
        MultipleOptions = false,
        Callback = function(opt) Aimbot.LockPart = opt[1] end
    })

    ComTab:CreateDropdown({
        Name = "Trigger Key",
        Options = {"MouseButton2","MouseButton1","E"},
        CurrentOption = {Aimbot.TriggerKeyName},
        MultipleOptions = false,
        Callback = function(opt) Aimbot.TriggerKeyName = opt[1] end
    })

    -- ✅ Team Check Toggle
    ComTab:CreateToggle({
        Name = "Team Check",
        CurrentValue = false,
        Callback = function(v)
            Aimbot.TeamCheck = v
        end
    })

    -- 🌈 رنگ FOV
    ComTab:CreateToggle({
        Name = "RGB FOV",
        CurrentValue = false,
        Callback = function(v) RGBEnabled = v end
    })

    ComTab:CreateColorPicker({
        Name = "FOV Color",
        Color = Color3.fromRGB(255,255,255),
        Callback = function(c)
            customColor = c
        end
    })
end






