--[[ 
    🌱 Grow a Garden - Solara V3 Duplication Script
    🐾 Supports Pets and Seeds
    🔁 Partial Name Matching
    🐝 Bee Swarm Style Pet-Follow
    ✅ Solara V3 Compatible (No GUI)
]]

repeat task.wait() until game:IsLoaded()
task.wait(3)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

--// Config
local PARTIAL_NAME = "Ostrich"    -- Partial match like "Ostrich"
local TYPE = "Pet"                -- "Pet" or "Seed"
local CLONE_EVERY = 3             -- Seconds between clones
local MAX_CLONES = 3              -- Max clones before stopping

--// State
local clones = 0

--// Pet follow function
local function makeFollow(model)
    if not model:IsA("Model") or not model.PrimaryPart then return end
    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bp.P = 12500
    bp.D = 1000
    bp.Position = model.PrimaryPart.Position
    bp.Parent = model.PrimaryPart

    RunService.Heartbeat:Connect(function()
        if HRP and model.PrimaryPart then
            bp.Position = HRP.Position + Vector3.new(math.random(-5, 5), 2, math.random(-5, 5))
        end
    end)
end

--// Find original Tool by partial match
local function findOriginal()
    for _, container in ipairs({Backpack, Character}) do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name, PARTIAL_NAME) then
                return item
            end
        end
    end
    return nil
end

--// Main Duplication Logic
task.spawn(function()
    while clones < MAX_CLONES do
        local original = findOriginal()
        if original then
            local clone = original:Clone()
            clone.Name = PARTIAL_NAME .. "_Clone" .. clones
            clones += 1

            if TYPE == "Pet" then
                -- PET: deploy to workspace and follow
                if clone:FindFirstChild("Handle") then
                    local petModel = Instance.new("Model", workspace)
                    clone.Parent = petModel
                    petModel.Name = clone.Name
                    petModel.PrimaryPart = clone.Handle
                    petModel:SetPrimaryPartCFrame(HRP.CFrame + Vector3.new(math.random(-6, 6), 0, math.random(-6, 6)))
                    makeFollow(petModel)
                else
                    warn("❌ Pet missing Handle:", clone.Name)
                end
            else
                -- SEED: put in backpack & auto equip
                clone.Parent = Backpack
                task.wait(0.1)
                LocalPlayer.Character.Humanoid:EquipTool(clone)
            end

            print("[✅ Duplicated]:", clone.Name)
        else
            warn("[⚠️ Not Found]:", PARTIAL_NAME)
        end

        task.wait(CLONE_EVERY)
    end

    print("[🛑 Finished] Max clones reached:", clones)
end)
