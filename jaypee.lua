--[[
    Grow a Garden - Advanced Pet Duplicator (Inventory Only)
    ✅ Auto-equip clones (optional)
    🐾 Clone multiple pets (Ostrich, Peacock, etc.)
    🎒 Stores clones in Backpack (does not auto-deploy)
    🧊 Solara V3 Compatible (no GUI required)
]]

repeat wait() until game:IsLoaded()
wait(3)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
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
local MAX_CLONES = 10            -- per pet
local AUTO_EQUIP = false         -- equip after cloning

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
