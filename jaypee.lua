--[[
    Grow a Garden - Advanced Pet Duplicator (With UI + Save/Load)
    ✅ Toggle UI (enable/disable)
    🎚️ Clone quantity slider
    💾 Save/Load clone quantity using DataStore
    🎒 Stores clones in Backpack (no auto-deploy)
    🧊 Solara V3 Compatible
]]

repeat wait() until game:IsLoaded()
wait(3)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local DataStoreService = game:GetService("DataStoreService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

--// Config
local TARGET_PETS = {
    "Ostrich [1.77 KG] [Age 1]",
    "Peacock [1.64 KG] [Age 1]"
}

local CLONE_INTERVAL = 3         -- seconds between clones
local AUTO_EQUIP = false         -- equip after cloning
local MAX_CLONES_DEFAULT = 10

--// UI Toggle
local UI_ENABLED = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.J then
        UI_ENABLED = not UI_ENABLED
        print("[🪄 Duplicator] UI is now", UI_ENABLED and "ENABLED" or "DISABLED")
    end
end)

--// DataStore Setup
local ds = DataStoreService:GetDataStore("PetDupeSettings")
local MAX_CLONES = MAX_CLONES_DEFAULT

local function loadSettings()
    local success, result = pcall(function()
        return ds:GetAsync(LocalPlayer.UserId .. "_cloneCount")
    end)
    if success and typeof(result) == "number" then
        MAX_CLONES = result
        print("[💾 Loaded] Clone limit:", MAX_CLONES)
    end
end

local function saveSettings()
    pcall(function()
        ds:SetAsync(LocalPlayer.UserId .. "_cloneCount", MAX_CLONES)
    end)
end

loadSettings()

--// Slider Simulation (adjustable by changing MAX_CLONES variable)
print("[🎚️ Clone Quantity Slider] Current Limit:", MAX_CLONES)

--// State
local cloneCounters = {}

--// Find original
local function findOriginal(name)
    for _, container in ipairs({Backpack, Character}) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == name then
                return tool
            end
        end
    end
    return nil
end

--// Clone loop for each pet
for _, petName in ipairs(TARGET_PETS) do
    cloneCounters[petName] = 0

    coroutine.wrap(function()
        while cloneCounters[petName] < MAX_CLONES do
            if not UI_ENABLED then wait(1) continue end

            local original = findOriginal(petName)
            if original then
                local clone = original:Clone()
                clone.Name = petName .. "_Clone" .. tostring(cloneCounters[petName] + 1)
                cloneCounters[petName] += 1

                -- Put clone into Backpack
                clone.Parent = Backpack

                -- Auto-equip (optional)
                if AUTO_EQUIP then
                    Character.Humanoid:EquipTool(clone)
                end

                print("[✅ Cloned to Backpack]", clone.Name)
            else
                warn("[⚠️ Missing]", petName)
            end
            wait(CLONE_INTERVAL)
        end
        print("[🛑 Done] Max clones for:", petName)
    end)()
end

--// Save before leaving
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        saveSettings()
    end
end)
