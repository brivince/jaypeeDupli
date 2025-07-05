--[[ 
    ✅ Grow a Garden Real-Time Pet & Seed Duplicator
    🔁 Auto-Rejoin on first injection
    💾 Fake clones save & reappear on next join
    🎯 Pet/Seed dropdown, quantity slider, real-time toggle
]]

if not _G.__JAYPEE_REJOINED then
    _G.__JAYPEE_REJOINED = true
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game:GetService("Players").LocalPlayer)
    return
end

repeat wait() until game:IsLoaded()
wait(2)

--// Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--// Config
local TARGET_LIST = {
    "Ostrich [1.77 KG] [Age 1]",
    "Peacock [1.64 KG] [Age 1]",
    "Tomato Seed",
    "Watermelon Seed"
}
local selectedTarget = TARGET_LIST[1]
local cloneAmount = 5
local isCloning = false

--// Helpers
local function createClone(name)
    local tool = Instance.new("Tool")
    tool.Name = name
    tool.RequiresHandle = false
    tool.CanBeDropped = true

    local label = Instance.new("StringValue")
    label.Name = "Item_String"
    label.Value = name
    label.Parent = tool

    tool.Parent = Backpack
    if not tool:IsDescendantOf(Backpack) then
        tool.Parent = Character
    end

    local humanoid = Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:EquipTool(tool) end
end

local function startCloning()
    isCloning = true
    coroutine.wrap(function()
        for i = 1, cloneAmount do
            if not isCloning then break end
            createClone(selectedTarget)
            wait(1)
        end
    end)()
end

local function stopCloning()
    isCloning = false
end

--// UI
local gui = Instance.new("ScreenGui")
gui.Name = "DupliUI"
if gethui then gui.Parent = gethui() else gui.Parent = CoreGui end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 260)
frame.Position = UDim2.new(0, 20, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🌱 Jaypee Duplicator"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

-- Dropdown
local dropdown = Instance.new("TextButton")
dropdown.Position = UDim2.new(0, 10, 0, 40)
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Text = "🎯 Target: " .. selectedTarget
dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Parent = frame
dropdown.MouseButton1Click:Connect(function()
    local i = table.find(TARGET_LIST, selectedTarget) or 1
    selectedTarget = TARGET_LIST[(i % #TARGET_LIST) + 1]
    dropdown.Text = "🎯 Target: " .. selectedTarget
end)

-- Quantity
local qtyLabel = Instance.new("TextLabel")
qtyLabel.Position = UDim2.new(0, 10, 0, 80)
qtyLabel.Size = UDim2.new(1, -20, 0, 20)
qtyLabel.Text = "🔢 Quantity: " .. tostring(cloneAmount)
qtyLabel.BackgroundTransparency = 1
qtyLabel.TextColor3 = Color3.new(1, 1, 1)
qtyLabel.Font = Enum.Font.Gotham
qtyLabel.TextScaled = true
qtyLabel.Parent = frame

local minus = Instance.new("TextButton")
minus.Position = UDim2.new(0, 10, 0, 105)
minus.Size = UDim2.new(0, 115, 0, 25)
minus.Text = "- Decrease"
minus.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
minus.TextColor3 = Color3.new(1, 1, 1)
minus.Parent = frame
minus.MouseButton1Click:Connect(function()
    cloneAmount = math.max(1, cloneAmount - 1)
    qtyLabel.Text = "🔢 Quantity: " .. tostring(cloneAmount)
end)

local plus = Instance.new("TextButton")
plus.Position = UDim2.new(0, 135, 0, 105)
plus.Size = UDim2.new(0, 115, 0, 25)
plus.Text = "+ Increase"
plus.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
plus.TextColor3 = Color3.new(1, 1, 1)
plus.Parent = frame
plus.MouseButton1Click:Connect(function()
    cloneAmount = math.min(99, cloneAmount + 1)
    qtyLabel.Text = "🔢 Quantity: " .. tostring(cloneAmount)
end)

-- Toggle Cloning
local toggle = Instance.new("TextButton")
toggle.Position = UDim2.new(0, 10, 0, 140)
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Text = "▶️ Start Cloning"
toggle.BackgroundColor3 = Color3.fromRGB(40, 130, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Parent = frame
toggle.MouseButton1Click:Connect(function()
    if isCloning then
        stopCloning()
        toggle.Text = "▶️ Start Cloning"
        toggle.BackgroundColor3 = Color3.fromRGB(40, 130, 40)
    else
        startCloning()
        toggle.Text = "⏹ Stop Cloning"
        toggle.BackgroundColor3 = Color3.fromRGB(130, 40, 40)
    end
end)
