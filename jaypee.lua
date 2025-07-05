--[[
    ✅ Grow a Garden Real-Time Pet & Seed Duplicator
    🧊 Fake pet & seed clones appear in Backpack (or auto-equip if blocked)
    🔁 Toggle cloning on/off in real time
    📋 Dropdown to choose pets or seeds
    🔢 Quantity selector for cloning
    🐾 Optional Pet-Follow Behavior
    💾 Saves & loads clones with mock DataStore
]]

repeat wait() until game:IsLoaded()
wait(2)

--// Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

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
local PET_FOLLOW = false

--// Clone Targets
local TARGET_LIST = {
    "Ostrich [1.77 KG] [Age 1]",
    "Peacock [1.64 KG] [Age 1]",
    "Tomato Seed",
    "Watermelon Seed"
}
local selectedTarget = TARGET_LIST[1]
local savedClones = {}
local cloneInstances = {}

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

    if AUTO_EQUIP then
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:EquipTool(tool) end
    end

    table.insert(cloneInstances, tool)
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
    cloneInstances = {}
    Backpack:ClearAllChildren()
    pcall(function()
        petDataStore:RemoveAsync(UserId .. "_Clones")
    end)
end

local function startCloning()
    IS_RUNNING = true
    coroutine.wrap(function()
        for i = 1, MAX_CLONES do
            if not IS_RUNNING then break end
            table.insert(savedClones, selectedTarget)
            createClone(selectedTarget)
            wait(CLONE_INTERVAL)
        end
    end)()
end

local function stopCloning()
    IS_RUNNING = false
end

local function petFollowLoop()
    game:GetService("RunService").Heartbeat:Connect(function()
        if not PET_FOLLOW then return end
        for _, clone in ipairs(cloneInstances) do
            if clone and clone:IsDescendantOf(workspace) then
                local targetPos = Character:GetPivot().Position + Vector3.new(math.random(-3,3), 0, math.random(-3,3))
                local hrp = Instance.new("Part")
                hrp.Anchored = true
                hrp.CanCollide = false
                hrp.Size = Vector3.new(1,1,1)
                hrp.CFrame = CFrame.new(targetPos)
                hrp.Parent = workspace
                TweenService:Create(clone, TweenInfo.new(0.5), {Position = targetPos}):Play()
                game:GetService("Debris"):AddItem(hrp, 1)
            end
        end
    end)
end

--// UI
local gui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local title = Instance.new("TextLabel")
local dropdown = Instance.new("TextButton")
local toggle = Instance.new("TextButton")
local saveBtn = Instance.new("TextButton")
local clearBtn = Instance.new("TextButton")
local amountBox = Instance.new("TextBox")
local followToggle = Instance.new("TextButton")

pcall(function()
    if gethui then gui.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = CoreGui else gui.Parent = CoreGui end
end)

frame.Size = UDim2.new(0, 280, 0, 300)
frame.Position = UDim2.new(0, 20, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = gui

-- Title
local function makeLabel(text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Position = UDim2.new(0, 0, 0, y)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.Parent = frame
    return label
end

makeLabel("🔁 Clone Tool", 0)

-- Dropdown
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

-- Quantity Input
amountBox.Position = UDim2.new(0, 10, 0, 80)
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.PlaceholderText = "🔢 Max Clones (e.g., 5)"
amountBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
amountBox.TextColor3 = Color3.new(1,1,1)
amountBox.Text = tostring(MAX_CLONES)
amountBox.Parent = frame
amountBox.FocusLost:Connect(function()
    local num = tonumber(amountBox.Text)
    if num and num >= 1 and num <= 50 then
        MAX_CLONES = num
    else
        amountBox.Text = tostring(MAX_CLONES)
    end
end)

-- Toggle Cloning
toggle.Position = UDim2.new(0, 10, 0, 120)
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Text = "▶️ Start Cloning"
toggle.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Parent = frame

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

-- Toggle Pet Follow
followToggle.Position = UDim2.new(0, 10, 0, 160)
followToggle.Size = UDim2.new(1, -20, 0, 30)
followToggle.Text = "🐾 Pet Follow: OFF"
followToggle.BackgroundColor3 = Color3.fromRGB(90, 60, 60)
followToggle.TextColor3 = Color3.new(1, 1, 1)
followToggle.Parent = frame
followToggle.MouseButton1Click:Connect(function()
    PET_FOLLOW = not PET_FOLLOW
    followToggle.Text = PET_FOLLOW and "🐾 Pet Follow: ON" or "🐾 Pet Follow: OFF"
end)

-- Save
saveBtn.Position = UDim2.new(0, 10, 1, -60)
saveBtn.Size = UDim2.new(0.5, -15, 0, 30)
saveBtn.Text = "💾 Save"
saveBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 80)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Parent = frame
saveBtn.MouseButton1Click:Connect(saveClones)

-- Clear
clearBtn.Position = UDim2.new(0.5, 5, 1, -60)
clearBtn.Size = UDim2.new(0.5, -15, 0, 30)
clearBtn.Text = "🗑️ Clear"
clearBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Parent = frame
clearBtn.MouseButton1Click:Connect(clearClones)

-- Start Pet Follow loop
petFollowLoop()

-- Load saved clones
loadClones()
