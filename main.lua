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

local PlayerTab = Window:CreateTab("Player", 4483362458) 
local ComTab = Window:CreateTab("Combat", 4483362458) 
local TelTab = Window:CreateTab("Teleport", 4483362458) 
local FarmTab = Window:CreateTab("Farm", 4483362458) 

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
















-- 🗺️ Teleport Dropdown (Replace old buttons)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 📍 مکان‌ها و مختصات‌ها
local Locations = {
    ["Spawn"] = Vector3.new(-733, 5, 2121),
    ["Bank"] = Vector3.new(-620, 6, 2040),
    ["LebasForoshi"] = Vector3.new(-645, 6, 2137),
    ["Amlak-Shoghl"] = Vector3.new(-632, 6, 2195),
}

-- 🚀 تابع تلپورت به مکان انتخابی
local function teleportToLocation(locationName)
    local targetPosition = Locations[locationName]
    if not targetPosition then
        warn("⚠️ مکان پیدا نشد: " .. tostring(locationName))
        return
    end

    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
        print("✅ تلپورت شدی به: " .. locationName)
    else
        warn("❌ HumanoidRootPart پیدا نشد!")
    end
end

-- 🎛 ایجاد Dropdown برای تلپورت بین مکان‌ها
local Dropdown = TelTab:CreateDropdown({
    Name = "Teleport to Location",
    Options = {"Spawn", "Bank", "LebasForoshi", "Amlak-Shoghl"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "TeleportLocationDropdown",
    Callback = function(Options)
        local chosen = Options[1]
        teleportToLocation(chosen)
    end,
})

















local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer


local TARGET_NAME = "P2"
local TELEPORT_OFFSET = Vector3.new(0, 3, 0)
local TIME_BETWEEN = 0.1 

local running = false
local targets = {}


local INSTANT_HOLD = 0

local function applyToPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.HoldDuration = INSTANT_HOLD
    end)
end


for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        applyToPrompt(obj)
    end
end


Workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        applyToPrompt(desc)
    end
end)


local function gatherTargets()
    targets = {}
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") and inst.Name == TARGET_NAME then
            table.insert(targets, inst)
        end
    end
end


Workspace.DescendantAdded:Connect(function(desc)
    if running and desc:IsA("BasePart") and desc.Name == TARGET_NAME then
        table.insert(targets, desc)
    end
end)


local function teleportTo(part)
    if not part or not part:IsDescendantOf(Workspace) then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    hrp.CFrame = CFrame.new(part.Position + TELEPORT_OFFSET)
    return true
end


local function simulateEClick()
    
    VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.01) 
    VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end


local function runAutoPickup()
    while running do
        gatherTargets()
        
        if #targets == 0 then
            task.wait(0.2)
            continue
        end
        
       
        for i = #targets, 1, -1 do
            if not targets[i] or not targets[i].Parent then
                table.remove(targets, i)
            end
        end
        
        if #targets == 0 then
            task.wait(0.2)
            continue
        end
        
        
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                table.sort(targets, function(a, b)
                    local distA = (hrp.Position - a.Position).Magnitude
                    local distB = (hrp.Position - b.Position).Magnitude
                    return distA < distB
                end)
            end
        end
        
       
        for i = 1, #targets do
            if not running then break end
            
            local part = targets[i]
            if not part or not part.Parent then
                continue
            end
            
            
            if teleportTo(part) then
                
                for j = 1, 3 do
                    if not part or not part.Parent then break end
                    simulateEClick()
                    task.wait(0.05) 
                end
                
                
                if part and part.Parent then
                    task.wait(TIME_BETWEEN)
                else
                   
                    break
                end
            end
        end
        
        task.wait(0.05) 
    end
end

-- Toggle
local Toggle = FarmTab:CreateToggle({
    Name = "Auto Farm Trash(Aval Roftegar Shavid)",
    CurrentValue = false,
    Flag = "Auto Farm Tras",
    Callback = function(Value)
        running = Value
        if running then
            task.spawn(runAutoPickup)
            print("✅ Auto Farm شروع شد")
        else
            print("⛔ Auto Farm متوقف شد.")
        end
    end,
})
































-- === Aimbot (self-contained) ===
do
    if getgenv().AirHub and getgenv().AirHub.Aimbot then
        -- اگر قبلاً لود شده باشه، کاری نکن
    else
        -- اجزای مورد نیاز
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local TweenService = game:GetService("TweenService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Camera = workspace.CurrentCamera
        local HttpService = game:GetService("HttpService") -- فقط در صورت نیاز برای تولید GUID (اختیاری)

        local pcall, next = pcall, next
        local Vector2new = Vector2.new
        local CFramenew = CFrame.new
        local Color3fromRGB = Color3.fromRGB
        local TweenInfonew = TweenInfo.new
        local mousemoverel = mousemoverel or (Input and Input.MouseMove)

        -- Environment
        getgenv().AirHub = getgenv().AirHub or {}
        getgenv().AirHub.Aimbot = getgenv().AirHub.Aimbot or {}
        local Environment = getgenv().AirHub.Aimbot

        Environment.Settings = Environment.Settings or {
            Enabled = false,
            TeamCheck = false,
            AliveCheck = true,
            WallCheck = false,
            Sensitivity = 0, -- seconds for tween
            ThirdPerson = false,
            ThirdPersonSensitivity = 3,
            TriggerKey = "MouseButton2",
            Toggle = false,
            LockPart = "Head"
        }

        Environment.FOVSettings = Environment.FOVSettings or {
            Enabled = true,
            Visible = true,
            Amount = 90,
            Color = Color3fromRGB(255, 255, 255),
            LockedColor = Color3fromRGB(255, 70, 70),
            Transparency = 0.5,
            Sides = 60,
            Thickness = 1,
            Filled = false
        }

        Environment.FOVCircle = Environment.FOVCircle or Drawing.new("Circle")
        Environment.FOVCircle.Color = Environment.FOVSettings.Color
        Environment.FOVCircle.Visible = false

        -- internal
        local RequiredDistance = 2000
        local Typing, Running, OriginalSensitivity = false, false, nil
        local ServiceConnections = {}
        local Animation = nil

        local function ConvertVector(Vector)
            return Vector2new(Vector.X, Vector.Y)
        end

        local function CancelLock()
            Environment.Locked = nil
            pcall(function()
                Environment.FOVCircle.Color = Environment.FOVSettings.Color
                if OriginalSensitivity then
                    UserInputService.MouseDeltaSensitivity = OriginalSensitivity
                end
                if Animation then
                    Animation:Cancel()
                    Animation = nil
                end
            end)
        end

        local function GetClosestPlayer()
            if not Environment.Locked then
                RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount) or 2000

                for _, v in next, Players:GetPlayers() do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
                        if Environment.Settings.TeamCheck and v.TeamColor == LocalPlayer.TeamColor then continue end
                        if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
                        if Environment.Settings.WallCheck then
                            local parts = Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())
                            if #parts > 0 then continue end
                        end

                        local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
                        Vector = ConvertVector(Vector)
                        local Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude

                        if Distance < RequiredDistance and OnScreen then
                            RequiredDistance = Distance
                            Environment.Locked = v
                        end
                    end
                end
            else
                local ok, lockedPart = pcall(function()
                    return Environment.Locked and Environment.Locked.Character and Environment.Locked.Character[Environment.Settings.LockPart]
                end)
                if ok and lockedPart then
                    local vec = ConvertVector(Camera:WorldToViewportPoint(lockedPart.Position))
                    if (UserInputService:GetMouseLocation() - vec).Magnitude > RequiredDistance then
                        CancelLock()
                    end
                else
                    CancelLock()
                end
            end
        end

        local function Load()
            OriginalSensitivity = UserInputService.MouseDeltaSensitivity

            ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
                -- draw FOV
                if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
                    local f = Environment.FOVCircle
                    f.Radius = Environment.FOVSettings.Amount
                    f.Thickness = Environment.FOVSettings.Thickness
                    f.Filled = Environment.FOVSettings.Filled
                    f.NumSides = Environment.FOVSettings.Sides
                    f.Color = Environment.FOVSettings.Color
                    f.Transparency = Environment.FOVSettings.Transparency
                    f.Visible = Environment.FOVSettings.Visible
                    local ml = UserInputService:GetMouseLocation()
                    f.Position = Vector2new(ml.X, ml.Y)
                else
                    pcall(function() Environment.FOVCircle.Visible = false end)
                end

                if Running and Environment.Settings.Enabled then
                    GetClosestPlayer()

                    if Environment.Locked then
                        local lockedPart = Environment.Locked and Environment.Locked.Character and Environment.Locked.Character[Environment.Settings.LockPart]
                        if Environment.Settings.ThirdPerson then
                            if lockedPart then
                                local Vector = Camera:WorldToViewportPoint(lockedPart.Position)
                                if mousemoverel then
                                    pcall(function()
                                        mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity,
                                                     (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
                                    end)
                                end
                            end
                        else
                            if lockedPart then
                                if Environment.Settings.Sensitivity > 0 then
                                    if Animation then Animation:Cancel() end
                                    Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, lockedPart.Position)})
                                    Animation:Play()
                                else
                                    Camera.CFrame = CFramenew(Camera.CFrame.Position, lockedPart.Position)
                                end
                                pcall(function() UserInputService.MouseDeltaSensitivity = 0 end)
                                pcall(function() Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor end)
                            end
                        end
                    end
                end
            end)

            ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
                if not Typing then
                    pcall(function()
                        local keyMatch = (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[#Environment.Settings.TriggerKey == 1 and string.upper(Environment.Settings.TriggerKey) or Environment.Settings.TriggerKey])
                        local mouseMatch = (Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey])
                        if keyMatch or mouseMatch then
                            if Environment.Settings.Toggle then
                                Running = not Running
                                if not Running then CancelLock() end
                            else
                                Running = true
                            end
                        end
                    end)
                end
            end)

            ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
                if not Typing then
                    if not Environment.Settings.Toggle then
                        pcall(function()
                            local keyMatch = (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[#Environment.Settings.TriggerKey == 1 and string.upper(Environment.Settings.TriggerKey) or Environment.Settings.TriggerKey])
                            local mouseMatch = (Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey])
                            if keyMatch or mouseMatch then
                                Running = false
                                CancelLock()
                            end
                        end)
                    end
                end
            end)

            ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function() Typing = true end)
            ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function() Typing = false end)
        end

        -- Functions
        Environment.Functions = Environment.Functions or {}

        function Environment.Functions:Exit()
            for _, v in pairs(ServiceConnections) do
                if v and v.Disconnect then
                    v:Disconnect()
                elseif v and v.Connected then
                    pcall(function() v:Disconnect() end)
                end
            end
            pcall(function() Environment.FOVCircle:Remove() end)
            getgenv().AirHub.Aimbot = nil
        end

        function Environment.Functions:Restart()
            for _, v in pairs(ServiceConnections) do
                if v and v.Disconnect then
                    v:Disconnect()
                elseif v and v.Connected then
                    pcall(function() v:Disconnect() end)
                end
            end
            ServiceConnections = {}
            Load()
        end

        function Environment.Functions:ResetSettings()
            Environment.Settings = {
                Enabled = false,
                TeamCheck = false,
                AliveCheck = true,
                WallCheck = false,
                Sensitivity = 0,
                ThirdPerson = false,
                ThirdPersonSensitivity = 3,
                TriggerKey = "MouseButton2",
                Toggle = false,
                LockPart = "Head"
            }

            Environment.FOVSettings = {
                Enabled = true,
                Visible = true,
                Amount = 90,
                Color = Color3fromRGB(255,255,255),
                LockedColor = Color3fromRGB(255,70,70),
                Transparency = 0.5,
                Sides = 60,
                Thickness = 1,
                Filled = false
            }
        end

        -- Boot
        Load()
    end

    -- === UI for Combat Tab ===
    local AimbotEnv = getgenv().AirHub and getgenv().AirHub.Aimbot
    if not AimbotEnv then
        ComTab:CreateParagraph({Title = "Aimbot", Content = "Failed to initialize Aimbot environment."})
        return
    end

    -- Main Toggle
    ComTab:CreateToggle({
        Name = "Enable Aimbot",
        CurrentValue = AimbotEnv.Settings.Enabled,
        Flag = "AimbotEnabled",
        Callback = function(val) AimbotEnv.Settings.Enabled = val end
    })

    -- FOV controls
    ComTab:CreateToggle({
        Name = "Show FOV",
        CurrentValue = AimbotEnv.FOVSettings.Visible,
        Flag = "AimbotFOVVisible",
        Callback = function(v) AimbotEnv.FOVSettings.Visible = v end
    })

    ComTab:CreateSlider({
        Name = "FOV Radius",
        Range = {10, 800},
        Increment = 5,
        Suffix = "px",
        CurrentValue = AimbotEnv.FOVSettings.Amount,
        Flag = "AimbotFOVRadius",
        Callback = function(val) AimbotEnv.FOVSettings.Amount = val end
    })

    ComTab:CreateColorPicker({
        Name = "FOV Color",
        Default = {AimbotEnv.FOVSettings.Color.R*255, AimbotEnv.FOVSettings.Color.G*255, AimbotEnv.FOVSettings.Color.B*255},
        Flag = "AimbotFOVColor",
        Callback = function(col) AimbotEnv.FOVSettings.Color = Color3.fromRGB(col[1], col[2], col[3]) end
    })

    ComTab:CreateToggle({
        Name = "Fill FOV",
        CurrentValue = AimbotEnv.FOVSettings.Filled,
        Flag = "AimbotFOVFilled",
        Callback = function(v) AimbotEnv.FOVSettings.Filled = v end
    })

    -- Target Options
    ComTab:CreateToggle({ Name = "Team Check", CurrentValue = AimbotEnv.Settings.TeamCheck, Flag = "AimbotTeamCheck", Callback = function(v) AimbotEnv.Settings.TeamCheck = v end })
    ComTab:CreateToggle({ Name = "Alive Check", CurrentValue = AimbotEnv.Settings.AliveCheck, Flag = "AimbotAliveCheck", Callback = function(v) AimbotEnv.Settings.AliveCheck = v end })
    ComTab:CreateToggle({ Name = "Wall Check", CurrentValue = AimbotEnv.Settings.WallCheck, Flag = "AimbotWallCheck", Callback = function(v) AimbotEnv.Settings.WallCheck = v end })

    ComTab:CreateDropdown({
        Name = "Lock Part",
        Options = {"Head","UpperTorso","HumanoidRootPart"},
        CurrentOption = {AimbotEnv.Settings.LockPart},
        MultipleOptions = false,
        Flag = "AimbotLockPart",
        Callback = function(opt) AimbotEnv.Settings.LockPart = opt[1] end
    })

    -- Sensitivity
    ComTab:CreateSlider({
        Name = "Sensitivity (sec)",
        Range = {0,1},
        Increment = 0.01,
        Suffix = "s",
        CurrentValue = AimbotEnv.Settings.Sensitivity,
        Flag = "AimbotSensitivity",
        Callback = function(v) AimbotEnv.Settings.Sensitivity = v end
    })

    -- Third person
    ComTab:CreateToggle({ Name = "Third Person Mode", CurrentValue = AimbotEnv.Settings.ThirdPerson, Flag = "Aimbot3P", Callback = function(v) AimbotEnv.Settings.ThirdPerson = v end })
    ComTab:CreateSlider({ Name = "3P Sensitivity", Range = {0.1,10}, Increment = 0.1, Suffix = "", CurrentValue = AimbotEnv.Settings.ThirdPersonSensitivity, Flag = "Aimbot3PSens", Callback = function(v) AimbotEnv.Settings.ThirdPersonSensitivity = v end })

    -- Trigger key dropdown (basic)
    ComTab:CreateDropdown({
        Name = "Trigger Key",
        Options = {"MouseButton2","MouseButton1","LeftShift","E"},
        CurrentOption = {AimbotEnv.Settings.TriggerKey},
        MultipleOptions = false,
        Flag = "AimbotTrigger",
        Callback = function(opt) AimbotEnv.Settings.TriggerKey = opt[1] end
    })

    ComTab:CreateToggle({ Name = "Toggle Mode (press to toggle)", CurrentValue = AimbotEnv.Settings.Toggle, Flag = "AimbotToggle", Callback = function(v) AimbotEnv.Settings.Toggle = v end })

    -- Utility Buttons
    ComTab:CreateButton({ Name = "Reset Settings", Callback = function() AimbotEnv.Functions:ResetSettings() print("Aimbot settings reset.") end })
    ComTab:CreateButton({ Name = "Restart Aimbot", Callback = function() AimbotEnv.Functions:Restart() print("Aimbot restarted.") end })
    ComTab:CreateButton({ Name = "Exit Aimbot", Callback = function() AimbotEnv.Functions:Exit() print("Aimbot exited.") end })
end

