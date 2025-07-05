--[[
    ✅ Grow a Garden Pet Cloner (Solara v3 Compatible)
    🧊 Fake pet clones appear in your Backpack or are equipped directly
    💾 UI shows cloned pets (now uses CoreGui for better compatibility)
    🔁 Load & Save to DataStore (client-side simulation)
]]

repeat wait() until game:IsLoaded()
wait(2)

--// Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local UserId = tostring(LocalPlayer.UserId)

--// DataStore Setup
local petDataStore = DataStoreService:GetDataStore("SavedPetClones")

--// Config
local TARGET_PETS = {
    "Ostrich [1.77 KG] [Age 1]",
    "Peacock [1.64 KG] [Age 1]"
}
local MAX_CLONES = 3
local CLONE_INTERVAL = 2
local AUTO_EQUIP = true

--// Data
local savedPets = {}

--// Parse metadata from name
local function parsePetString(name)
    local base, weight, age = name:match("^(.-)%s%[(.-)%]%s%[Age%s(%d+)%]$")
    return {
        full = name,
        base = base or name,
        weight = weight or "?",
        age = tonumber(age) or 0
    }
end

--// Create fake Tool clone
local function createFakePet(petData)
    local tool = Instance.new("Tool")
    tool.Name = petData.full
    tool.RequiresHandle = false
    tool.CanBeDropped = true

    local label = Instance.new("StringValue")
    label.Name = "Item_String"
    label.Value = petData.full
    label.Parent = tool

    -- Try placing in Backpack
    tool.Parent = Backpack

    -- If blocked, place into Character instead
    if not tool:IsDescendantOf(Backpack) then
        tool.Parent = Character
    end

    return tool
end

--// Save clones to DataStore
local function saveClonedPets()
    local toSave = {}
    for _, pet in ipairs(savedPets) do
        table.insert(toSave, pet.full)
    end
    pcall(function()
        petDataStore:SetAsync(UserId .. "_ClonedPets", toSave)
    end)
    print("[💾 Saved cloned pets]")
end

--// Load saved clones from DataStore
local function loadClonedPets()
    local success, data = pcall(function()
        return petDataStore:GetAsync(UserId .. "_ClonedPets")
    end)
    if success and data then
        for _, name in ipairs(data) do
            local meta = parsePetString(name)
            table.insert(savedPets, meta)
            createFakePet(meta)
        end
        print("[📦 Loaded]", #savedPets, "pets")
    end
end

--// Clear saved data
local function clearSavedPets()
    savedPets = {}
    Backpack:ClearAllChildren()
    pcall(function()
        petDataStore:RemoveAsync(UserId .. "_ClonedPets")
    end)
    print("[🗑️ Cleared saved pets]")
end

--// Clone pets
for _, petName in ipairs(TARGET_PETS) do
    for i = 1, MAX_CLONES do
        local petMeta = parsePetString(petName)
        petMeta.full = petName .. "_Clone" .. i
        table.insert(savedPets, petMeta)
        createFakePet(petMeta)

        if AUTO_EQUIP then
            local tool = Backpack:FindFirstChild(petMeta.full) or Character:FindFirstChild(petMeta.full)
            if tool then
                Character.Humanoid:EquipTool(tool)
            end
        end
        wait(CLONE_INTERVAL)
    end
end

--// UI Setup
local gui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local title = Instance.new("TextLabel")
local petList = Instance.new("TextLabel")
local saveBtn = Instance.new("TextButton")
local clearBtn = Instance.new("TextButton")

-- Properties
gui.Name = "PetClonerGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui -- Use CoreGui for exploit compatibility

frame.Size = UDim2.new(0, 240, 0, 200)
frame.Position = UDim2.new(0, 20, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = gui

-- Title
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🐾 Cloned Pets"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

-- Pet List
petList.Position = UDim2.new(0, 0, 0, 35)
petList.Size = UDim2.new(1, 0, 1, -75)
petList.BackgroundTransparency = 1
petList.TextColor3 = Color3.fromRGB(180, 255, 180)
petList.TextXAlignment = Enum.TextXAlignment.Left
petList.TextYAlignment = Enum.TextYAlignment.Top
petList.Font = Enum.Font.Code
petList.TextWrapped = true
petList.TextScaled = false
petList.TextSize = 14
petList.Parent = frame

local function updateUI()
    local lines = {}
    for _, pet in ipairs(savedPets) do
        table.insert(lines, string.format("%s | %s | Age %d", pet.base, pet.weight, pet.age))
    end
    petList.Text = table.concat(lines, "\n")
end

-- Buttons
saveBtn.Position = UDim2.new(0, 10, 1, -35)
saveBtn.Size = UDim2.new(0.5, -15, 0, 30)
saveBtn.Text = "💾 Save"
saveBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Parent = frame

clearBtn.Position = UDim2.new(0.5, 5, 1, -35)
clearBtn.Size = UDim2.new(0.5, -15, 0, 30)
clearBtn.Text = "🗑️ Clear"
clearBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Parent = frame

-- Callbacks
saveBtn.MouseButton1Click:Connect(function()
    saveClonedPets()
end)

clearBtn.MouseButton1Click:Connect(function()
    clearSavedPets()
    updateUI()
end)

-- Run UI update
loadClonedPets()
updateUI()

print("[✅ Cloner Ready] Pets visible and UI loaded")
