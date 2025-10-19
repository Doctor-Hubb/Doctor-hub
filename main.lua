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
















local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- تنظیمات
local TARGET_NAME = "P2"
local TELEPORT_OFFSET = Vector3.new(0, 3, 0)
local PICKUP_WAIT = 1.5
local TIME_BETWEEN = 0.3
local NEAR_THRESHOLD = 5

local running = false
local targets = {}

-- تابع جمع‌آوری همه آیتم‌ها
local function gatherTargets()
    targets = {}
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") and inst.Name == TARGET_NAME then
            table.insert(targets, inst)
        end
    end
end

-- وقتی پارت جدید اسپاون شد
Workspace.DescendantAdded:Connect(function(desc)
    if running and desc:IsA("BasePart") and desc.Name == TARGET_NAME then
        table.insert(targets, desc)
    end
end)

-- تلپورت به پارت
local function teleportTo(part)
    if not part or not part:IsDescendantOf(Workspace) then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    hrp.CFrame = CFrame.new(part.Position + TELEPORT_OFFSET)
    return true
end

-- شبیه‌سازی صحیح نگه داشتن کلید E به مدت 1 ثانیه
local function simulateEPressHold()
    -- فشار دادن کلید E
    VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    -- نگه داشتن به مدت 1 ثانیه
    task.wait(1)
    -- رها کردن کلید E
    VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- فرایند اصلی بهبود یافته
local function runAutoPickup()
    while running do
        gatherTargets()
        
        if #targets == 0 then
            task.wait(1)
            continue
        end
        
        for i = #targets, 1, -1 do
            if not running then break end
            
            local part = targets[i]
            if not part or not part.Parent then
                table.remove(targets, i)
                continue
            end
            
            -- تلپورت به آیتم
            if teleportTo(part) then
                task.wait(0.3)
                
                -- نگه داشتن دکمه E به مدت 1 ثانیه
                simulateEPressHold()
                
                -- صبر برای جمع‌آوری و سپس بررسی آیتم بعدی
                task.spawn(function()
                    local t = 0
                    while part.Parent and t < PICKUP_WAIT do
                        if not running then return end
                        task.wait(0.2)
                        t += 0.2
                    end
                    -- وقتی جمع‌آوری انجام شد، به سراغ پارت بعدی برو
                    task.wait(TIME_BETWEEN)
                end)
            end
        end
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
        else
            print("⛔ AutoPickup متوقف شد.")
        end
    end,
})


















-- LocalScript: AutoMagnetPickup.lua
-- قرار بدید داخل StarterPlayerScripts (فقط برای بازی خودت / تست)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInput = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- === تنظیمات قابل تغییر ===
local TARGET_NAME = "P2"                 -- اسم پارت‌ها
local TELEPORT_FRONT_OFFSET = Vector3.new(0, 2.5, -1) -- موقعیت نهایی نسبی نسبت به HRP (پایین/جلو)
local TWEEN_TIME = 0.5                   -- مدت زمان کشیدن پارت تا جلوی بازیکن
local HOLD_E_TIME = 1.2                  -- مدت نگه داشتن E
local PICKUP_TIMEOUT = 3.0               -- منتظر موندن برای حذف شدن پارت
local SEARCH_INTERVAL = 1.0              -- فاصله زمانی برای جستجوی مجدد پارت‌ها
local MAX_DISTANCE_TO_PULL = 200         -- حداکثر فاصله‌ای که پارت را برای کشیدن مدنظر می‌گیریم
local ALLOW_NETWORK_OWNERSHIP = true     -- سعی کن SetNetworkOwner بزنی یا نه (ممکنه نیاز به دسترسی سرور داشته باشه)

-- وضعیت
local running = false
local activePull = false
local targetsQueue = {}

-- کمک: جمع‌آوری تمام پارت‌های TARGET_NAME
local function gatherTargets()
    local list = {}
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") and inst.Name == TARGET_NAME then
            table.insert(list, inst)
        end
    end
    return list
end

-- کمک: محاسبه CFrame هدف جلوی پلیر (توجه کن جهت دوربین یا HRP رو میشه تغییر داد)
local function getTargetCFrameInFrontOfPlayer()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    -- استفاده از CFrame دوربین تا جلو رو متناسب با جهت دید بازیکن انتخاب کنه:
    local cam = workspace.CurrentCamera
    local forward = cam and cam.CFrame.LookVector or hrp.CFrame.LookVector
    -- نقطه‌ای در جلو و کمی بالاتر از HRP
    local basePos = hrp.Position
    -- فاصله جلو را بسته به TELEPORT_FRONT_OFFSET.z منطقاً منفی است (زیر و جلو)
    local finalPos = basePos + Vector3.new(TELEPORT_FRONT_OFFSET.X, TELEPORT_FRONT_OFFSET.Y, TELEPORT_FRONT_OFFSET.Z)
    -- بهترکن: مقداری جلو قرار بده بر اساس جهت دوربین:
    finalPos = basePos + forward.Unit * math.abs(TELEPORT_FRONT_OFFSET.Z) + Vector3.new(TELEPORT_FRONT_OFFSET.X, TELEPORT_FRONT_OFFSET.Y, 0)
    return CFrame.new(finalPos)
end

-- تلاش برای دادن NetworkOwner به لوکال پلیر (برای فیزیک روان‌تر)
local function trySetNetworkOwner(part)
    if not ALLOW_NETWORK_OWNERSHIP then return end
    if not part or not part:IsA("BasePart") then return end
    -- pcall چون ممکنه سرور اجازه نده
    pcall(function()
        if part.SetNetworkOwner then
            part:SetNetworkOwner(LocalPlayer)
        end
    end)
end

-- حذف NetworkOwner (برگردوندن به سرور)
local function clearNetworkOwner(part)
    if not ALLOW_NETWORK_OWNERSHIP then return end
    if not part or not part:IsA("BasePart") then return end
    pcall(function()
        if part.SetNetworkOwner then
            part:SetNetworkOwner(nil)
        end
    end)
end

-- حرکت دادن پارت به جلوی پلیر با Tween
local function pullPartToPlayer(part)
    if not part or not part.Parent then return false end
    local targetCFrame = getTargetCFrameInFrontOfPlayer()
    if not targetCFrame then return false end

    -- قطع برخورد برای جلوگیری از گیر کردن
    pcall(function() part.CanCollide = false end)

    -- اگر خیلی دور است، ردش کن یا نادیده بگیر
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and (hrp.Position - part.Position).Magnitude > MAX_DISTANCE_TO_PULL then
        return false
    end

    -- سعی کن network owner رو ست کنی
    trySetNetworkOwner(part)

    -- اگر part anchored هست، tween کردن CFrame مستقیم کار می‌کنه. اگر نیست هم تابع معمولی کار می‌کنه.
    local success, err = pcall(function()
        local ti = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goal = {CFrame = targetCFrame}
        local tween = TweenService:Create(part, ti, goal)
        tween:Play()
        tween.Completed:Wait()
    end)

    -- در صورت خطا یا عدم موفقیت، سعی کن مستقیماً CFrame ست کنی
    if not success then
        pcall(function() part.CFrame = targetCFrame end)
    end

    return true
end

-- نگه داشتن E با VirtualInputManager
local function pressAndHoldE()
    pcall(function()
        VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(HOLD_E_TIME)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

-- انتظار تا پارت حذف شود یا timeout
local function waitForPickedOrTimeout(part, timeout)
    local t = 0
    while t < timeout do
        if not running then return false end
        if not part.Parent then
            return true
        end
        task.wait(0.2)
        t = t + 0.2
    end
    return false
end

-- روند اصلی: کشیدن و pickup
local function runMagnetPickupLoop()
    while running do
        -- اگر صف خالی بود، تجدید جمع‌آوری کن
        if #targetsQueue == 0 then
            targetsQueue = gatherTargets()
            if #targetsQueue == 0 then
                task.wait(SEARCH_INTERVAL)
                continue
            end
        end

        -- از انتهای لیست شروع کن تا پارت‌های جدید با اندکس مواجه نشن
        for i = #targetsQueue, 1, -1 do
            if not running then break end
            local part = targetsQueue[i]

            -- حذف از صف اگر دیگر وجود ندارد
            if not part or not part.Parent then
                table.remove(targetsQueue, i)
                continue
            end

            -- جلوگیری از همزمانی
            if activePull then
                task.wait(0.1)
                continue
            end

            activePull = true
            -- تلاش برای کشیدن پارت
            local ok = pcall(function() ok = pullPartToPlayer(part) end)

            if ok then
                -- صبر کمی تا پارت در جای خودش بنشینه
                task.wait(0.15)

                -- نگه داشتن E برای pickup
                pressAndHoldE()

                -- منتظر برداشته شدن یا timeout
                local picked = waitForPickedOrTimeout(part, PICKUP_TIMEOUT)

                -- اگر برداشته شد، حذفش از صف
                if picked then
                    for idx = #targetsQueue, 1, -1 do
                        if targetsQueue[idx] == part then
                            table.remove(targetsQueue, idx)
                            break
                        end
                    end
                else
                    -- اگر pickup انجام نشد، می‌تونی تصمیم بگیری که دوباره retry کنی
                    -- اینجا فقط صبر می‌کنیم و به آیتم بعدی می‌ریم
                end
            end

            -- پاکسازی network owner
            clearNetworkOwner(part)

            activePull = false

            -- فاصله بین آیتم‌ها
            task.wait(0.15)
        end

        -- یک وقفه کوتاه قبل از حلقه مجدد
        task.wait(0.5)
    end
end

-- اضافه کردن listener برای آیتم‌های جدید (تا خودشون هم وارد صف بشن اگر Toggle فعال باشه)
Workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("BasePart") and desc.Name == TARGET_NAME then
        table.insert(targetsQueue, desc)
    end
end)

-- === Toggle UI (همان قالب شما؛ FarmTab یا Tab را با متغیر مناسب عوض کن) ===
local Toggle = FarmTab:CreateToggle({
    Name = "Magnet Pickup P2",
    CurrentValue = false,
    Flag = "MagnetPickupP2",
    Callback = function(Value)
        running = Value
        if running then
            targetsQueue = gatherTargets()
            task.spawn(runMagnetPickupLoop)
            print("✅ Magnet Pickup شروع شد")
        else
            print("⛔ Magnet Pickup متوقف شد")
        end
    end,
})



