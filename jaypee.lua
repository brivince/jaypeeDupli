--[[
    ✅ Grow a Garden Pet & Seed Duplicator (No UI)
    🧊 Fake clones saved directly into inventory
    💾 Clones persist using mock DataStore
]]

repeat wait() until game:IsLoaded()
wait(2)

--// Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local UserId = tostring(LocalPlayer.UserId)

--// DataStore Setup
local petDataStore = DataStoreService:GetDataStore("SavedClones")

--// Config
local CLONE_MODE = "Pet" -- or "Seed"
local TARGET_LIST = {
    "Ostrich [1.93 KG] [Age 2]",
    "Peacock [1.64 KG] [Age 1]",
    "Tomato Seed",
    "Watermelon Seed"
}
local CLONE_AMOUNT = 15

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

    return tool
end

--// Save clones to mock DataStore
local function saveClones(cloneNames)
    pcall(function()
        petDataStore:SetAsync(UserId .. "_Clones", cloneNames)
    end)
end

--// Load clones on join
local function loadClones()
    local success, data = pcall(function()
        return petDataStore:GetAsync(UserId .. "_Clones")
    end)
    if success and data then
        for _, name in ipairs(data) do
            createClone(name)
        end
    end
end

--// Main: clone and save
local function run()
    local clones = {}
    for _, name in ipairs(TARGET_LIST) do
        for i = 1, CLONE_AMOUNT do
            createClone(name)
            table.insert(clones, name)
            wait(0.5)
        end
    end
    saveClones(clones)
end

-- Run on script execution
loadClones()
run()
