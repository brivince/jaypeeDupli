--[[ 
    Grow a Garden - Duplicator Script
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
local PARTIAL_NAME = "Ostrich [1.77 KG] [Age 1]"   -- Name match (can be partial like "Ostrich")
local TYPE = "Pet"               -- "Seed" or "Pet"
local CLONE_EVERY = 3            -- seconds between each duplication
local MAX_CLONES = 10            -- stop after this many clones

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
            bp.Position = HRP.Position + Vector3.new(math.random(-4,4), 2, math.random(-4,4))
        end
    end)
end

--// Find original by partial match
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

--// Main duplication loop
coroutine.wrap(function()
    while clones < MAX_CLONES do
        local original = findOriginal()
        if original then
            local clone = original:Clone()
            clones += 1
            clone.Name = PARTIAL_NAME .. "_Clone" .. clones

            if TYPE == "Pet" then
                clone.Parent = workspace
                clone:MoveTo(HRP.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
                makeFollow(clone)
            else
                clone.Parent = Backpack
            end

            print("[✅ Duplicated]:", clone.Name)
        else
            warn("[⚠️ Not Found]:", PARTIAL_NAME)
        end
        wait(CLONE_EVERY)
    end

    print("[🛑 Done] Max clones reached:", clones)
end)()
