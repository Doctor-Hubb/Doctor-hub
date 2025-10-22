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
































-- === Simple Aimbot + FOV (light) ===
do
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    -- state
    local Aimbot = {
        Enabled = false,
        FOVEnabled = true,
        FOVRadius = 120,
        Sensitivity = 0.35, -- 0..1, 0 = instant snap
        LockPart = "Head",
        TriggerKey = "MouseButton2", -- hold to aim
    }

    -- Drawing FOV circle
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Radius = Aimbot.FOVRadius
    circle.Color = Color3.fromRGB(255,255,255)
    circle.Thickness = 1
    circle.NumSides = 64
    circle.Filled = false
    circle.Transparency = 0.6

    -- helper: get all potential targets
    local function getPlayers()
        local out = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Aimbot.LockPart) and p.Character:FindFirstChildOfClass("Humanoid") then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(out, p)
                end
            end
        end
        return out
    end

    -- helper: screen pos and on screen check
    local function getScreenPos(part)
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        return Vector2.new(pos.X, pos.Y), onScreen
    end

    -- find closest to mouse within FOV
    local function findClosest()
        local mousePos = UserInputService:GetMouseLocation()
        local closestDist = Aimbot.FOVRadius
        local closestPlayer = nil

        for _, p in ipairs(getPlayers()) do
            local part = p.Character and p.Character:FindFirstChild(Aimbot.LockPart)
            if part then
                local screenPos, onScreen = getScreenPos(part)
                if onScreen then
                    local dist = (mousePos - screenPos).Magnitude
                    if dist <= closestDist then
                        closestDist = dist
                        closestPlayer = p
                    end
                end
            end
        end

        return closestPlayer
    end

    local aiming = false

    -- try to move mouse (smooth) or fallback to camera CFrame
    local function aimAt(part)
        if not part then return end
        local screenPos, onScreen = getScreenPos(part)
        if not onScreen then return end

        local mousePos = UserInputService:GetMouseLocation()
        local dx = (screenPos.X - mousePos.X)
        local dy = (screenPos.Y - mousePos.Y)

        -- sensitivity scale: smaller value -> faster movement
        local sens = math.clamp(Aimbot.Sensitivity, 0, 1)

        -- try mousemoverel if available (many executors provide it)
        local moved = false
        if mousemoverel then
            pcall(function()
                -- multiply to convert to relative movement; tweak factor if needed
                local factor = 1
                mousemoverel(dx * sens * factor, dy * sens * factor)
                moved = true
            end)
        end

        if not moved then
            -- fallback: rotate camera towards target smoothly
            local root = Camera.CFrame.Position
            local newCFrame = CFrame.new(root, part.Position)
            if sens <= 0 then
                Camera.CFrame = newCFrame
            else
                -- lerp camera CFrame direction
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(root, part.Position), sens)
            end
        end
    end

    -- RenderStepped loop
    local conn
    conn = RunService.RenderStepped:Connect(function()
        -- draw fov circle at mouse
        if Aimbot.FOVEnabled and Aimbot.Enabled then
            local m = UserInputService:GetMouseLocation()
            circle.Visible = true
            circle.Position = Vector2.new(m.X, m.Y)
            circle.Radius = Aimbot.FOVRadius
        else
            circle.Visible = false
        end

        -- if user is holding trigger and enabled, find and aim
        if Aimbot.Enabled and aiming then
            local target = findClosest()
            if target and target.Character and target.Character:FindFirstChild(Aimbot.LockPart) then
                aimAt(target.Character[Aimbot.LockPart])
            end
        end
    end)

    -- input events for hold trigger
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        -- compare input type with configured trigger
        -- support MouseButton1/2 and Keyboard keys like E
        if input.UserInputType == Enum.UserInputType[ Aimbot.TriggerKey ] or (input.UserInputType == Enum.UserInputType.MouseButton1 and Aimbot.TriggerKey == "MouseButton1") or (input.UserInputType == Enum.UserInputType.MouseButton2 and Aimbot.TriggerKey == "MouseButton2") then
            aiming = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType[ Aimbot.TriggerKey ] or (input.UserInputType == Enum.UserInputType.MouseButton1 and Aimbot.TriggerKey == "MouseButton1") or (input.UserInputType == Enum.UserInputType.MouseButton2 and Aimbot.TriggerKey == "MouseButton2") then
            aiming = false
        end
    end)

    -- ===== UI in Combat tab =====
    ComTab:CreateToggle({
        Name = "Aimbot (hold trigger)",
        CurrentValue = false,
        Flag = "SimpleAimbotEnable",
        Callback = function(val) Aimbot.Enabled = val end,
    })

    ComTab:CreateToggle({
        Name = "Show FOV",
        CurrentValue = true,
        Flag = "SimpleAimbotFOVShow",
        Callback = function(v) Aimbot.FOVEnabled = v end,
    })

    ComTab:CreateSlider({
        Name = "FOV Radius",
        Range = {30, 600},
        Increment = 5,
        Suffix = "px",
        CurrentValue = Aimbot.FOVRadius,
        Flag = "SimpleAimbotFOVRadius",
        Callback = function(v) Aimbot.FOVRadius = v end,
    })

    ComTab:CreateSlider({
        Name = "Sensitivity",
        Range = {0, 1},
        Increment = 0.05,
        Suffix = "",
        CurrentValue = Aimbot.Sensitivity,
        Flag = "SimpleAimbotSensitivity",
        Callback = function(v) Aimbot.Sensitivity = v end,
    })

    ComTab:CreateDropdown({
        Name = "Lock Part",
        Options = {"Head","UpperTorso","HumanoidRootPart"},
        CurrentOption = {Aimbot.LockPart},
        MultipleOptions = false,
        Flag = "SimpleAimbotLockPart",
        Callback = function(opt) Aimbot.LockPart = opt[1] end,
    })

    ComTab:CreateDropdown({
        Name = "Trigger Key",
        Options = {"MouseButton2","MouseButton1","E"},
        CurrentOption = {Aimbot.TriggerKey},
        MultipleOptions = false,
        Flag = "SimpleAimbotTrigger",
        Callback = function(opt) Aimbot.TriggerKey = opt[1] end,
    })

    -- cleanup on exit (optional)
    -- return a handle if you want to stop later: e.g., getgenv().SimpleAimbotHandle = {Disconnect = function() conn:Disconnect(); circle:Remove() end}
end


