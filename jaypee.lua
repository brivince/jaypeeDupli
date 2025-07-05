--[[
    ✅ Grow a Garden Pet & Seed Duplicator (Deploy to Pet GUI)
    🧊 Clones only created and listed in pet UI (max 3 active)
    ❌ No auto-equip, no join reload
]]

repeat wait() until game:IsLoaded()
wait(2)

--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--// Config
local CLONE_MODE = "Pet"
local TARGET_LIST = {
    "Bald Eagle",
    "Honey Bee",
    "Ostrich"
}
local MAX_ACTIVE_PETS = 3

--// Helpers
local function deployPet(name)
    local guiFolder = LocalPlayer:FindFirstChild("PlayerGui")
    if not guiFolder then return end

    local activePets = guiFolder:FindFirstChild("Pet_Active")
    if not activePets then return end

    local currentCount = #activePets:GetChildren()
    if currentCount >= MAX_ACTIVE_PETS then return end

    local petFrame = Instance.new("Frame")
    petFrame.Name = name
    petFrame.Size = UDim2.new(0, 200, 0, 100)
    petFrame.BackgroundColor3 = Color3.fromRGB(140, 90, 60)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    nameLabel.Parent = petFrame

    petFrame.Parent = activePets
end

--// Deploy pets to GUI
for _, petName in ipairs(TARGET_LIST) do
    deployPet(petName)
    wait(1)
end
