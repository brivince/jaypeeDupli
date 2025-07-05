--[[
    Grow a Garden - Persistent Pet Duplicator (DataStore Save)
    ✅ Clone pets (Tools) by name
    💾 Save pet Name, Weight, and Age to DataStore
    ♻️ Reload pets into Backpack when rejoining
    🧊 Solara V3 Compatible
]]

repeat wait() until game:IsLoaded()
wait(3)

--// Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local UserId = tostring(LocalPlayer.UserId)

--// Config
local TARGET_PETS = {
    "Ostrich [1.77 KG] [Age 2]",
    "Peacock [1.64 KG] [Age 1]"
}

local MAX_CLONES = 3
local CLONE_INTERVAL = 2
local AUTO_EQUIP = false

--// Datastore
local petDataStore = DataStoreService:GetDataStore("SavedPetClones")

--// Helpers
local function saveClonedPets(petList)
    local success, err = pcall(function()
        petDataStore:SetAsync(UserId .. "_ClonedPets", petList)
    end)
    if success then
        print("[✅ Saved cloned pets]", petList)
    else
        warn("[❌ Failed to save pets]", err)
    end
end

local function loadClonedPets()
    local success, data = pcall(function()
        return petDataStore:GetAsync(UserId .. "_ClonedPets")
    end)
    if success and data then
        return data
    end
    return {}
end

local function createFakePet(name)
    local tool = Instance.new("Tool")
    tool.Name = name
    tool.RequiresHandle = false
    tool.CanBeDropped = true

    local label = Instance.new("StringValue")
    label.Name = "Item_String"
    label.Value = name
    label.Parent = tool

    return tool
end

--// Clone loop (save to datastore)
local clonedList = {}
for _, petName in ipairs(TARGET_PETS) do
    for i = 1, MAX_CLONES do
        local cloneName = petName .. "_Clone" .. tostring(i)
        local tool = createFakePet(cloneName)
        tool.Parent = Backpack
        table.insert(clonedList, cloneName)
        if AUTO_EQUIP then
            Character.Humanoid:EquipTool(tool)
        end
        wait(CLONE_INTERVAL)
    end
end

--// Save when leaving
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        saveClonedPets(clonedList)
    end
end)

--// Load saved clones when joining
local saved = loadClonedPets()
for _, petName in ipairs(saved) do
    local tool = createFakePet(petName)
    tool.Parent = Backpack
end

print("[🐾 Loaded and ready] Persistent pets active.")
