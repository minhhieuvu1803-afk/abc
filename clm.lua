local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local playerGui = player:WaitForChild("PlayerGui")

-- Tạo ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "UltimateSafeFarmFixed"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- HÀM HỖ TRỢ LÀM ĐẸP UI
local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
end

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 200) 
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
addCorner(frame, 8)

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "🛡️ Ultimate Safe Farm 🛡️"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.new(1, 1, 1)
title.Active = true
title.Parent = frame
addCorner(title, 8)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 8)
titleFix.Position = UDim2.new(0, 0, 1, -8)
titleFix.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleFix.BorderSizePixel = 0
titleFix.Parent = title

-- CLOSE
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = frame
addCorner(closeBtn, 8)

-- ================= CÁC THÀNH PHẦN UI ================= --
local autoSwingBtn = Instance.new("TextButton")
autoSwingBtn.Size = UDim2.new(0.85, 0, 0, 35)
autoSwingBtn.Position = UDim2.new(0.075, 0, 0, 55)
autoSwingBtn.Text = "Auto Swing: OFF"
autoSwingBtn.Font = Enum.Font.GothamSemibold
autoSwingBtn.TextSize = 13
autoSwingBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
autoSwingBtn.TextColor3 = Color3.new(1, 1, 1)
autoSwingBtn.Parent = frame
addCorner(autoSwingBtn, 6)

local autoFarmBtn = Instance.new("TextButton")
autoFarmBtn.Size = UDim2.new(0.85, 0, 0, 35)
autoFarmBtn.Position = UDim2.new(0.075, 0, 0, 105)
autoFarmBtn.Text = "Safe Auto Farm: OFF"
autoFarmBtn.Font = Enum.Font.GothamSemibold
autoFarmBtn.TextSize = 13
autoFarmBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
autoFarmBtn.TextColor3 = Color3.new(1, 1, 1)
autoFarmBtn.Parent = frame
addCorner(autoFarmBtn, 6)

-- ================= LOGIC BIẾN & HÀM ================= --
local autoSwingEnabled = false
local autoFarmEnabled = false
local currentTween = nil
local FLY_SPEED = 70 

local function makeDraggable(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(title, frame)

local function getMobsFolder()
    if workspace:FindFirstChild("Mobs") then return workspace.Mobs:GetChildren() end
    if workspace:FindFirstChild("Enemies") then return workspace.Enemies:GetChildren() end
    if workspace:FindFirstChild("Monsters") then return workspace.Monsters:GetChildren() end
    return workspace:GetChildren()
end

local function getNearestMob()
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local nearestDist = math.huge
    local nearestMob = nil

    for _, obj in ipairs(getMobsFolder()) do
        if obj:IsA("Model") and obj ~= char then
            local hum = obj:FindFirstChild("Humanoid")
            local mobRoot = obj:FindFirstChild("HumanoidRootPart")
            if hum and mobRoot and hum.Health > 0 and not game.Players:GetPlayerFromCharacter(obj) then
                local dist = (root.Position - mobRoot.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestMob = obj
                end
            end
        end
    end
    return nearestMob
end

-- ================= VÒNG LẶP AUTO FARM (GIẢ LẬP NGƯỜI) ================= --
task.spawn(function()
    while task.wait(math.random(15, 35) / 100) do 
        if autoSwingEnabled or autoFarmEnabled then
            local char = player.Character
            if char then
                local equippedTool = char:FindFirstChildOfClass("Tool")
                if equippedTool and math.random(1, 100) > 10 then 
                    equippedTool:Activate() 
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if autoFarmEnabled then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local mob = getNearestMob()
                
                if root and mob and mob:FindFirstChild("HumanoidRootPart") then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                    
                    root.AssemblyLinearVelocity = Vector3.zero
                    local mobRoot = mob.HumanoidRootPart
                    
                    local rX = math.random(-25, 25) / 10
                    local rZ = math.random(-25, 25) / 10
                    local rY = 6 + (math.random(-5, 5) / 10) 
                    
                    local targetCFrame = mobRoot.CFrame * CFrame.new(rX, rY, rZ) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    local dist = (root.Position - targetCFrame.Position).Magnitude
                    local timeToTravel = dist / FLY_SPEED
                    if timeToTravel < 0.1 then timeToTravel = 0.1 end
                    
                    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
                    currentTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
                    currentTween:Play()
                    
                    local elapsed = 0
                    while autoFarmEnabled and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and elapsed < timeToTravel do
                        elapsed += task.wait()
                        root.AssemblyLinearVelocity = Vector3.zero
                    end
                    
                    if currentTween then currentTween:Cancel() end
                    
                    if autoFarmEnabled and (not mob:FindFirstChild("Humanoid") or mob.Humanoid.Health <= 0) then
                        task.wait(math.random(5, 15) / 10)
                    end
                end
            end
        end
    end
end)

-- ================= SỰ KIỆN NÚT BẤM ================= --
local function toggleColor(btn, state)
    btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 80) or Color3.fromRGB(70, 70, 70)
end

-- Dùng Activated thay vì MouseButton1Click để hỗ trợ cực nhạy cho cả PC và Mobile
autoSwingBtn.Activated:Connect(function()
    autoSwingEnabled = not autoSwingEnabled
    autoSwingBtn.Text = autoSwingEnabled and "Auto Swing: ON" or "Auto Swing: OFF"
    toggleColor(autoSwingBtn, autoSwingEnabled)
end)

autoFarmBtn.Activated:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    autoFarmBtn.Text = autoFarmEnabled and "Safe Auto Farm: ON" or "Safe Auto Farm: OFF"
    toggleColor(autoFarmBtn, autoFarmEnabled)
    
    if not autoFarmEnabled and currentTween then
        currentTween:Cancel()
        local char = player.Character
        if char then
            for _, name in ipairs({"HumanoidRootPart", "Head", "Torso", "UpperTorso", "LowerTorso"}) do
                local part = char:FindFirstChild(name)
                if part and part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

closeBtn.Activated:Connect(function()
    autoSwingEnabled = false
    autoFarmEnabled = false
    if currentTween then currentTween:Cancel() end
    gui:Destroy()
end) 
