--[[
    @author brivince
    @description Grow a Garden duplicator UI with saving, pet-follow, and quantity duplication
]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--// DataStore
local CloneStore = DataStoreService:GetDataStore("DuplicatorSave")

--// UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DuplicatorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Grow a Garden | Duplicator"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local function createLabel(text, position)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Position = position
    label.Size = UDim2.new(0, 50, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = frame
    return label
end

createLabel("Type:", UDim2.new(0, 10, 0, 40))

local itemTypeDropdown = Instance.new("TextButton")
itemTypeDropdown.Text = "Seed"
itemTypeDropdown.Position = UDim2.new(0, 70, 0, 40)
itemTypeDropdown.Size = UDim2.new(0, 100, 0, 20)
itemTypeDropdown.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
itemTypeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
itemTypeDropdown.Font = Enum.Font.SourceSans
itemTypeDropdown.TextSize = 16
itemTypeDropdown.Parent = frame

createLabel("Item:", UDim2.new(0, 10, 0, 70))

local itemDropdown = Instance.new("TextButton")
itemDropdown.Text = "None"
itemDropdown.Position = UDim2.new(0, 70, 0, 70)
itemDropdown.Size = UDim2.new(0, 200, 0, 20)
itemDropdown.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
itemDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
itemDropdown.Font = Enum.Font.SourceSans
itemDropdown.TextSize = 16
itemDropdown.Parent = frame

createLabel("Qty:", UDim2.new(0, 10, 0, 100))

local quantityBox = Instance.new("TextBox")
quantityBox.Text = "1"
quantityBox.Position = UDim2.new(0, 70, 0, 100)
quantityBox.Size = UDim2.new(0, 50, 0, 20)
quantityBox.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
quantityBox.Font = Enum.Font.SourceSans
quantityBox.TextSize = 16
quantityBox.ClearTextOnFocus = false
quantityBox.Parent = frame

local duplicateButton = Instance.new("TextButton")
duplicateButton.Text = "Duplicate Now"
duplicateButton.Position = UDim2.new(0, 10, 0, 130)
duplicateButton.Size = UDim2.new(0, 280, 0, 30)
duplicateButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
duplicateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
duplicateButton.Font = Enum.Font.SourceSansBold
duplicateButton.TextSize = 18
duplicateButton.Parent = frame

local autoToggle = Instance.new("TextButton")
autoToggle.Text = "Auto: OFF"
autoToggle.Position = UDim2.new(0, 10, 0, 170)
autoToggle.Size = UDim2.new(0, 280, 0, 30)
autoToggle.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
autoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoToggle.Font = Enum.Font.SourceSansBold
autoToggle.TextSize = 18
autoToggle.Parent = frame

--// Globals
local itemType = "Seed"
local selectedItem = nil
local autoEnabled = false

local function getItems()
    local found = {}
    for _, container in ipairs({Backpack, Character}) do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") or item:IsA("Model") then
                found[item.Name] = item
            end
        end
    end
    return found
end

local function refreshItemList()
    local items = getItems()
    local keys = {}
    for k in pairs(items) do table.insert(keys, k) end
    itemDropdown.Text = keys[1] or "None"
    selectedItem = keys[1] or nil
end

local function saveToDataStore(name)
    local success, err = pcall(function()
        CloneStore:SetAsync(LocalPlayer.UserId .. ":" .. name, true)
    end)
    if not success then warn("Save failed:", err) end
end

local function petFollowScript(petModel)
    if not petModel:IsA("Model") or not petModel.PrimaryPart then return end
    local follow = Instance.new("BodyPosition")
    follow.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    follow.P = 15000
    follow.D = 1000
    follow.Position = petModel.PrimaryPart.Position
    follow.Parent = petModel.PrimaryPart

    RunService.Heartbeat:Connect(function()
        local root = Character:FindFirstChild("HumanoidRootPart")
        if root then
            follow.Position = root.Position + Vector3.new(math.random(-4,4), 2, math.random(-4,4))
        end
    end)
end

local function duplicate(count)
    if not selectedItem then return end
    local original = getItems()[selectedItem]
    if not original then return end

    for _ = 1, count do
        local clone = original:Clone()
        if itemType == "Seed" then
            clone.Parent = Backpack
        elseif itemType == "Pet" then
            clone.Parent = Workspace
            clone:MoveTo(Character:GetPivot().Position + Vector3.new(math.random(-4,4), 0, math.random(-4,4)))
            petFollowScript(clone)
        end
        saveToDataStore(clone.Name)
        task.wait(0.1)
    end
end

itemTypeDropdown.MouseButton1Click:Connect(function()
    itemType = itemType == "Seed" and "Pet" or "Seed"
    itemTypeDropdown.Text = itemType
end)

itemDropdown.MouseButton1Click:Connect(function()
    refreshItemList()
end)

duplicateButton.MouseButton1Click:Connect(function()
    local qty = tonumber(quantityBox.Text) or 1
    duplicate(qty)
end)

autoToggle.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    autoToggle.Text = autoEnabled and "Auto: ON" or "Auto: OFF"
end)

RunService.Heartbeat:Connect(function()
    if autoEnabled and selectedItem then
        local qty = tonumber(quantityBox.Text) or 1
        duplicate(qty)
    end
end)

-- Load on start
refreshItemList()
