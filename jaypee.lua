--[[
    ✅ Grow a Garden Real-Time Pet & Seed Duplicator
    🧊 Fake pet & seed clones appear in Backpack (or auto-equip if blocked)
    🔁 Toggle cloning on/off in real time
    📋 Dropdown to choose pets or seeds
    🌱 Full seed support (Tool or Item_String)
    💾 Saves & loads clones with mock DataStore
]]

repeat wait() until game:IsLoaded()
wait(2)

--// Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local UserId = tostring(LocalPlayer.UserId)

--// DataStore Setup
local petDataStore = DataStoreService:GetDataStore("SavedClones")

--// Config
local AUTO_EQUIP = true
local CLONE_INTERVAL = 2
local MAX_CLONES = 5
local CLONE_MODE = "Pet" -- or "Seed"
local IS_RUNNING = false

--// Clone Targets (Pet or Seed mode)
local TARGET_LIST = {
    "Ostrich [1.77 KG] [Age 1]",
    "Peacock [1.64 KG] [Age 1]",
    "Tomato Seed",
    "Watermelon Seed"
}
local selectedTarget = TARGET_LIST[1]

--// Data
local savedClones = {}

--// Helpers
local function createClone(name)
    local tool = Instance.new("Tool")
    tool.Name = name
    tool.RequiresHandle = false
    tool.CanBeDropped = true

    if CLONE_MODE == "Seed" then
        local label = Instance.new("StringValue")
        label.Name = "Item_String"
        label.Value = name
        label.Parent = tool
    else
        local label = Instance.new("StringValue")
        label.Name = "Item_String"
        label.Value = name
        label.Parent = tool
    end

    tool.Parent = Backpack
    if not tool:IsDescendantOf(Backpack) then
        tool.Parent = Character
    end

    if AUTO_EQUIP then
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:EquipTool(tool) end
    end

    return tool
end

local function saveClones()
    local toSave = {}
    for _, clone in ipairs(savedClones) do
        table.insert(toSave, clone)
    end
    pcall(function()
        petDataStore:SetAsync(UserId .. "_Clones", toSave)
    end)
end

local function loadClones()
    local success, data = pcall(function()
        return petDataStore:GetAsync(UserId .. "_Clones")
    end)
    if success and data then
        for _, name in ipairs(data) do
            table.insert(savedClones, name)
            createClone(name)
        end
    end
end

local function clearClones()
    savedClones = {}
    Backpack:ClearAllChildren()
    pcall(function()
        petDataStore:RemoveAsync(UserId .. "_Clones")
    end)
end

local function startCloning()
    IS_RUNNING = true
    coroutine.wrap(function()
        local count = 0
        while IS_RUNNING and count < MAX_CLONES do
            count += 1
            table.insert(savedClones, selectedTarget)
            createClone(selectedTarget)
            wait(CLONE_INTERVAL)
        end
    end)()
end

local function stopCloning()
    IS_RUNNING = false
end

--// UI Setup
local gui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local title = Instance.new("TextLabel")
local dropdown = Instance.new("TextButton")
local toggle = Instance.new("TextButton")
local saveBtn = Instance.new("TextButton")
local clearBtn = Instance.new("TextButton")

-- Parent
if gethui then gui.Parent = gethui() else gui.Parent = CoreGui end

-- Style
frame.Size = UDim2.new(0, 260, 0, 240)
frame.Position = UDim2.new(0, 20, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = gui

-- Title
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🔁 Clone Tool"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

-- Dropdown for targets
dropdown.Position = UDim2.new(0, 10, 0, 40)
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Text = "🎯 Select: " .. selectedTarget
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Parent = frame

dropdown.MouseButton1Click:Connect(function()
    local currentIndex = table.find(TARGET_LIST, selectedTarget) or 1
    local nextIndex = (currentIndex % #TARGET_LIST) + 1
    selectedTarget = TARGET_LIST[nextIndex]
    dropdown.Text = "🎯 Select: " .. selectedTarget
    CLONE_MODE = selectedTarget:lower():find("seed") and "Seed" or "Pet"
end)

-- Toggle button
toggle.Position = UDim2.new(0, 10, 0, 80)
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Text = "▶️ Start Cloning"
toggle.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Parent = frame

-- Toggle action
toggle.MouseButton1Click:Connect(function()
    if IS_RUNNING then
        stopCloning()
        toggle.Text = "▶️ Start Cloning"
        toggle.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    else
        startCloning()
        toggle.Text = "⏸ Stop Cloning"
        toggle.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    end
end)

-- Save button
saveBtn.Position = UDim2.new(0, 10, 1, -60)
saveBtn.Size = UDim2.new(0.5, -15, 0, 30)
saveBtn.Text = "💾 Save"
saveBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 80)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Parent = frame
saveBtn.MouseButton1Click:Connect(saveClones)

-- Clear button
clearBtn.Position = UDim2.new(0.5, 5, 1, -60)
clearBtn.Size = UDim2.new(0.5, -15, 0, 30)
clearBtn.Text = "🗑️ Clear"
clearBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Parent = frame
clearBtn.MouseButton1Click:Connect(function()
    clearClones()
end)

-- Startup
loadClones()
