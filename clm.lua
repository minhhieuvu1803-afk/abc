local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Giao diện UI siêu tối giản
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "SafeKillAura"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 150, 0, 50)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true 

local uic = Instance.new("UICorner", frame)
uic.CornerRadius = UDim.new(0, 8)

local auraBtn = Instance.new("TextButton", frame)
auraBtn.Size = UDim2.new(1, -10, 1, -10)
auraBtn.Position = UDim2.new(0, 5, 0, 5)
auraBtn.Text = "Kill Aura: OFF"
auraBtn.Font = Enum.Font.GothamBold
auraBtn.TextSize = 14
auraBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
auraBtn.TextColor3 = Color3.new(1, 1, 1)

local uic2 = Instance.new("UICorner", auraBtn)
uic2.CornerRadius = UDim.new(0, 6)

-- ================= LOGIC KILL AURA AN TOÀN ================= --
local auraEnabled = false

-- LỚP BẢO VỆ 1: Tầm đánh thực tế
-- Không để quá 15. Từ 10-12 là an toàn nhất để qua mặt Anti-Reach
local safeKillRange = 12 

auraBtn.MouseButton1Click:Connect(function()
    auraEnabled = not auraEnabled
    auraBtn.Text = auraEnabled and "Kill Aura: ON" or "Kill Aura: OFF"
    auraBtn.BackgroundColor3 = auraEnabled and Color3.fromRGB(50, 150, 80) or Color3.fromRGB(70, 70, 70)
end)

-- Vòng lặp quét quái
task.spawn(function()
    while true do
        -- LỚP BẢO VỆ 2: Delay ngẫu nhiên (Giả lập người bấm)
        -- Random từ 0.25s đến 0.45s để tránh bị Anti-Spam khóa mõm
        task.wait(math.random(25, 45) / 100) 
        
        if auraEnabled then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local tool = char:FindFirstChildOfClass("Tool")
                
                if tool and tool:FindFirstChild("Handle") then
                    
                    -- Tỉ lệ 15% sẽ không vung vũ khí (Giả lập con người bị mỏi tay/đánh hụt)
                    if math.random(1, 100) > 15 then
                        tool:Activate()
                    end
                    
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj ~= char then
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            local enemyRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                            
                            if hum and hum.Health > 0 and enemyRoot and not game.Players:GetPlayerFromCharacter(obj) then
                                local dist = (root.Position - enemyRoot.Position).Magnitude
                                
                                -- Chỉ chém khi quái ở sát bên cạnh
                                if dist <= safeKillRange then
                                    if firetouchinterest then
                                        firetouchinterest(enemyRoot, tool.Handle, 0)
                                        firetouchinterest(enemyRoot, tool.Handle, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
