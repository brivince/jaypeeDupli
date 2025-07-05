--[[
    Grow a Garden - Advanced Pet Duplicator
    ✅ Auto-equip clones
    🐾 Clone multiple pets (Ostrich, Peacock, etc.)
    📦 Store clones in a custom folder in Workspace
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
local AUTO_EQUIP = true          -- equip after cloning
local USE_CUSTOM_FOLDER = true

--// State
local cloneCounters = {}
local PetClonesFolder = nil

--// Setup folder
if USE_CUSTOM_FOLDER then
    PetClonesFolder = Workspace:FindFirstChild("ClonedPets")
    if not PetClonesFolder then
        PetClonesFolder = Instance.new("Folder")
        PetClonesFolder.Name = "ClonedPets"
        PetClonesFolder.Parent = Workspace
    end
end

--// Make pets follow
local function makeFollow(model)
    if not model:IsA("Model") or not model.PrimaryPart then return end
    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bp.P = 15000
    bp.D = 1000
    bp.Position = model.PrimaryPart.Position
    bp.Parent = model.PrimaryPart

    RunService.Heartbeat:Connect(function()
        if HRP and model.PrimaryPart then
            bp.Position = HRP.Position + Vector3.new(math.random(-4,4), 2, math.random(-4,4))
        end
    end)
end

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

                -- Set parent
                if USE_CUSTOM_FOLDER then
                    clone.Parent = PetClonesFolder
                else
                    clone.Parent = Workspace
                end

                -- Move and follow
                if clone:IsA("Tool") then
                    local success, model = pcall(function()
                        if clone:FindFirstChildOfClass("Model") then
                            return clone:FindFirstChildOfClass("Model")
                        elseif clone:IsA("Model") then
                            return clone
                        else
                            return nil
                        end
                    end)

                    if success and model then
                        makeFollow(model)
                    end
                end

                clone:MoveTo(HRP.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))

                -- Auto-equip
                if AUTO_EQUIP and clone:IsDescendantOf(Backpack) then
                    Character.Humanoid:EquipTool(clone)
                end

                print("[✅ Cloned]", clone.Name)
            else
                warn("[⚠️ Missing]", petName)
            end
            wait(CLONE_INTERVAL)
        end
        print("[🛑 Done] Max clones for:", petName)
    end)()
end
