--[[
    @author brivince
    @description Grow a Garden duplicator script (no GUI, compatible with Solara V3)
    This version auto-duplicates a selected seed or pet every few seconds.
]]

-- Wait for game to fully load
repeat wait() until game:IsLoaded()
wait(3)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--// Configuration
local ITEM_NAME = "Bee Egg" -- Change this to the exact name of the seed or pet you want to duplicate
local ITEM_TYPE = "Pet"     -- Choose between "Seed" or "Pet"
local DUPLICATE_INTERVAL = 3 -- Time in seconds between each auto-duplicate
local DUPLICATE_AMOUNT = 1   -- How many copies per cycle

--// Pet-follow script
local function petFollowScript(petModel)
    if not petModel:IsA("Model") or not petModel.PrimaryPart then return end
    local follow = Instance.new("BodyPosition")
    follow.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    follow.P = 15000
    follow.D = 1000
    follow.Position = petModel.PrimaryPart.Position
    follow.Parent = petModel.PrimaryPart

    RunService.Heartbeat:Connect(function()
        local root = Character:FindFirstChild("HumanoidRootPart")
        if root and petModel.PrimaryPart then
            follow.Position = root.Position + Vector3.new(math.random(-4,4), 2, math.random(-4,4))
        end
    end)
end

--// Get original item
local function findOriginalItem()
    for _, container in ipairs({Backpack, Character}) do
        for _, item in ipairs(container:GetChildren()) do
            if item.Name == ITEM_NAME then
                return item
            end
        end
    end
    return nil
end

--// Duplication loop
coroutine.wrap(function()
    while true do
        local original = findOriginalItem()
        if original then
            for i = 1, DUPLICATE_AMOUNT do
                local clone = original:Clone()
                if ITEM_TYPE == "Seed" then
                    clone.Parent = Backpack
                elseif ITEM_TYPE == "Pet" then
                    clone.Parent = workspace
                    clone:MoveTo(Character:GetPivot().Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
                    petFollowScript(clone)
                end
                wait(0.1)
            end
        else
            warn("Item not found: " .. ITEM_NAME)
        end
        wait(DUPLICATE_INTERVAL)
    end
end)()

print("[Duplicator] Started for: " .. ITEM_NAME)
