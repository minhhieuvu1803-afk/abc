-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ================== SETTINGS & STATE ==================
local Config = {
    KillAura = false,
    MultiAttack = false,
    SpeedRun = false,
    SpeedAttackValue = 0.15,
    MultiRange = 15,
    SpeedRunValue = 24,
    ChestESP = false
}

-- ================== UI SYSTEM (Tối ưu) ==================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "GeminiRedesign"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 230, 0, 350)
main.Position = UDim2.new(0.05, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = BoxBlur -- Bo góc mượt

local header = Instance.new("TextButton", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.Text = "  COMBAT MENU v2.0"
header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
header.TextColor3 = Color3.new(1, 1, 1)
header.Font = Enum.Font.GothamBold
header.TextSize = 14
header.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", header)

local container = Instance.new("ScrollingFrame", main)
container.Position = UDim2.new(0, 5, 0, 45)
container.Size = UDim2.new(1, -10, 1, -50)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 2
container.CanvasSize = UDim2.new(0, 0, 1.5, 0)

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)

-- ================== HÀM HỖ TRỢ (Utility) ==================
local function createToggle(name, configKey, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        btn.Text = name .. (Config[configKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 70)
        btn.TextColor3 = Color3.new(1, 1, 1)
        if callback then callback(Config[configKey]) end
    end)
end

local function getSword()
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end
    
    -- Nếu chưa cầm kiếm, tự tìm trong túi (Backpack)
    for _, v in pairs(player.Backpack:GetChildren()) do
        if v:IsA("Tool") then 
            v.Parent = char 
            return v 
        end
    end
end

-- ================== LOGIC CẢI TIẾN ==================

-- 1. Kill Aura (Tìm mục tiêu gần nhất thay vì quét hết)
task.spawn(function()
    while true do
        if Config.KillAura then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local sword = getSword()
            
            if root and sword then
                local closestEnemy = nil
                local shortestDist = Config.MultiRange

                -- Chỉ quét các Model trong Workspace để bớt lag
                for _, m in pairs(workspace:GetChildren()) do
                    if m:IsA("Model") and m ~= char and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
                        local enemyRoot = m:FindFirstChild("HumanoidRootPart")
                        if enemyRoot then
                            local dist = (enemyRoot.Position - root.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                closestEnemy = enemyRoot
                            end
                        end
                    end
                end

                if closestEnemy then
                    -- Dịch chuyển nhẹ đến sau lưng mục tiêu (Tránh bị đánh trả)
                    root.CFrame = closestEnemy.CFrame * CFrame.new(0, 0, 3)
                    sword:Activate()
                end
            end
        end
        task.wait(Config.SpeedAttackValue)
    end
end)

-- 2. Speed Run (Dùng Loop mượt hơn)
RunService.Heartbeat:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = Config.SpeedRun and Config.SpeedRunValue or 16
    end
end)

-- 3. ESP Hệ thống (Tự động nhận diện rương mới)
local function applyESP(part)
    local chestColors = { White = 1, Green = 1, Blue = 1, Purple = 1, Yellow = 1, Red = 1 }
    if part:IsA("Part") and chestColors[part.Name] then
        local hl = Instance.new("Highlight", part)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Enabled = Config.ChestESP
        -- Lưu vào tag để quản lý
        part:SetAttribute("IsChest", true)
    end
end

-- Quét cũ
for _, v in pairs(workspace:GetDescendants()) do applyESP(v) end
-- Đón đầu rương mới spawn
workspace.DescendantAdded:Connect(applyESP)

-- ================== ADD COMPONENTS TO UI ==================
createToggle("Kill Aura", "KillAura")
createToggle("Speed Run", "SpeedRun")
createToggle("Chest ESP", "ChestESP", function(val)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Parent:GetAttribute("IsChest") then
            v.Enabled = val
        end
    end
end)

-- Slider Speed (Đơn giản hóa)
local speedLabel = Instance.new("TextLabel", container)
speedLabel.Size = UDim2.new(1,0,0,20)
speedLabel.Text = "Speed: " .. Config.SpeedRunValue
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)

-- Nút thu gọn menu
local collapsed = false
header.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    container.Visible = not collapsed
    main:TweenSize(collapsed and UDim2.new(0,230,0,40) or UDim2.new(0,230,0,350), "Out", "Quad", 0.3, true)
end)
