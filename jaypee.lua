--[[
    Grow a Garden - Persistent Pet Duplicator (Full UI + Save/Load)
    ✅ Clone pets and view them in a UI
    💾 Manual Save and Clear buttons
    📊 Metadata parsed: name, weight, age
    🧊 Solara V3 Compatible
]]

repeat wait() until game:IsLoaded()
wait(2)

--// Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local UserId = tostring(LocalPlayer.UserId)

--// DataStore
local petDataStore = DataStoreService:GetDataStore("SavedPetClones")

--// Config
local TARGET_PETS = {
    "Ostrich [1.77 KG] [Age 1]",
    "Peacock [1.64 KG] [Age 1]"
}
local MAX_CLONES = 3
local CLONE_INTERVAL = 2
local AUTO_EQUIP = false

--// Metadata storage
local savedPets = {}

--// Helper: Parse metadata
local function parsePetString(name)
    local base, weight, age = name:match("^(.-)%s%[(.-)%]%s%[Age%s(%d+)%]$")
    return {
        full = name,
        base = base or name,
        weight = weight or "??",
        age = tonumber(age) or 0
    }
end

--// Helper: Create fake tool with metadata
local function createFakePet(petData)
    local tool = Instance.new("Tool")
    tool.Name = petData.full
    tool.RequiresHandle = false
    tool.CanBeDropped = true

    local meta = Instance.new("StringValue")
    meta.Name = "Item_String"
    meta.Value = petData.full
    meta.Parent = tool

    return tool
end

--// Save pets
local function saveClonedPets()
    local data = {}
    for _, pet in ipairs(savedPets) do
        table.insert(data, pet.full)
    end
    pcall(function()
        petDataStore:SetAsync(UserId .. "_ClonedPets", data)
    end)
    print("[💾 Saved pets to DataStore]")
end

--// Load pets
local function loadClonedPets()
    local success, data = pcall(function()
        return petDataStore:GetAsync(UserId .. "_ClonedPets")
    end)
    if success and data then
        for _, name in ipairs(data) do
            local meta = parsePetString(name)
            table.insert(savedPets, meta)
            local tool = createFakePet(meta)
            tool.Parent = Backpack
        end
        print("[📦 Loaded pets]", #savedPets)
    end
end

--// Clear pets
local function clearSavedPets()
    savedPets = {}
    Backpack:ClearAllChildren()
    pcall(function()
        petDataStore:RemoveAsync(UserId .. "_ClonedPets")
    end)
    print("[🗑️ Cleared saved pets]")
end

--// Clone logic
for _, petName in ipairs(TARGET_PETS) do
    for i = 1, MAX_CLONES do
        local petMeta = parsePetString(petName)
        petMeta.full = petName .. "_Clone" .. i
        table.insert(savedPets, petMeta)

        local tool = createFakePet(petMeta)
        tool.Parent = Backpack

        if AUTO_EQUIP then
            Character.Humanoid:EquipTool(tool)
        end

        wait(CLONE_INTERVAL)
    end
end

--// UI Setup
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "PetClonerUI"

local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0, 20, 0.5, -100)
frame.Size = UDim2.new(0, 220, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🐾 Saved Pets"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local petList = Instance.new("TextLabel", frame)
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

local function updatePetList()
    local lines = {}
    for _, pet in ipairs(savedPets) do
        table.insert(lines, string.format("%s | %s | Age %d", pet.base, pet.weight, pet.age))
    end
    petList.Text = table.concat(lines, "\n")
end

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Position = UDim2.new(0, 10, 1, -35)
saveBtn.Size = UDim2.new(0.5, -15, 0, 30)
saveBtn.Text = "💾 Save"
saveBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.MouseButton1Click:Connect(function()
    saveClonedPets()
end)

local clearBtn = Instance.new("TextButton", frame)
clearBtn.Position = UDim2.new(0.5, 5, 1, -35)
clearBtn.Size = UDim2.new(0.5, -15, 0, 30)
clearBtn.Text = "🗑️ Clear"
clearBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
clearBtn.TextColor3 = Color3.new(1,1,1)
clearBtn.MouseButton1Click:Connect(function()
    clearSavedPets()
    updatePetList()
end)

--// Initialize
loadClonedPets()
updatePetList()

print("[🎛️ UI ready] View, save, and clear pets in UI")
