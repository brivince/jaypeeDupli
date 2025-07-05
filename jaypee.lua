--[[ 
    Grow a Garden - Duplicator Script (Fixed Auto-Deploy)
    🐾 Supports seeds and pets
    🔁 Partial name match (e.g. "Ostrich")
    🐝 Real pet-follow behavior (Bee Swarm style)
    ✅ Solara V3 compatible (no UI)
]]

repeat wait() until game:IsLoaded()
wait(3)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

--// Config
local PARTIAL_NAME = "Ostrich"   -- Partial name is okay
local TYPE = "Pet"               -- "Seed" or "Pet"
local CLONE_EVERY = 3            -- seconds between duplication
local MAX_CLONES = 3             -- stop after this many clones

--// State
local clones = 0

--// Pet follow logic
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
            bp.Position = HRP.Position + Vector3.new(math.random(-4, 4), 2, math.random(-4, 4))
        end
    end)
end

--// Find the original Tool or Pet
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

--// Duplication logic
coroutine.wrap(function()
    while clones < MAX_CLONES do
        local original = findOriginal()
        if original then
            local clone = original:Clone()
            clone.Name = PARTIAL_NAME .. "_Clone" .. clones
            clones += 1

            if TYPE == "Pet" then
                -- Ensure pet has a valid model and PrimaryPart
                if clone:FindFirstChild("Handle") then
                    local petModel = Instance.new("Model", workspace)
                    clone.Parent = petModel
                    petModel.Name = clone.Name

                    clone.Handle.Anchored = false
                    petModel.PrimaryPart = clone.Handle
                    petModel:SetPrimaryPartCFrame(HRP.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))

                    makeFollow(petModel)
                else
                    warn("❌ Clone has no Handle for pet:", clone.Name)
                end
            else
                -- Seed goes to Backpack and gets equipped
                clone.Parent = Backpack
                wait(0.1)
                LocalPlayer.Character.Humanoid:EquipTool(clone)
            end

            print("[✅ Duplicated]:", clone.Name)
        else
            warn("[⚠️ Not Found]:", PARTIAL_NAME)
        end
        wait(CLONE_EVERY)
    end

    print("[🛑 Done] Max clones reached:", clones)
end)()
