--[[ 
🌿 Grow a Garden - Full Solara V3 Duplicator
UI Features:
✅ Dropdown for seed/pet
✅ Clone count slider
✅ Toggle real-time ON/OFF
✅ Combined PET + SEED support
🐝 Bee Swarm style pet-follow
--]]

repeat task.wait() until game:IsLoaded()
task.wait(3)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

--// UI Setup (Solara V3)
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/3xploits7/Solara/main/Lib.lua"))()
local win = lib:Window("🌱 Grow a Garden", Color3.fromRGB(102, 255, 153), Enum.KeyCode.RightControl)
local tab = win:Tab("🧬 Duplicator")

--// Config Variables
local selectedName = ""
local maxClones = 5
local realTimeToggle = false

tab:Dropdown("🔽 Select Pet/Seed", {"Ostrich", "Bee", "Apple", "Carrot"}, function(value)
    selectedName = value
end)

tab:Slider("🔁 Max Clones", 1, 50, 5, function(value)
    maxClones = value
end)

tab:Toggle("🟢 Enable Duplicator", false, function(state)
    realTimeToggle = state
end)

--// Follow Logic
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

--// Find Tool Matching Name
local function findOriginal(partialName)
    for _, container in ipairs({Backpack, Character}) do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name, partialName) then
                return item
            end
        end
    end
    return nil
end

--// Duplication Coroutine
task.spawn(function()
    while true do
        if realTimeToggle and selectedName ~= "" then
            local clones = 0
            while clones < maxClones and realTimeToggle do
                local original = findOriginal(selectedName)
                if original then
                    local clone = original:Clone()
                    clones += 1
                    clone.Name = selectedName .. "_Clone" .. clones

                    if string.find(original.Name:lower(), "seed") then
                        clone.Parent = Backpack
                        task.wait(0.1)
                        if LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid:EquipTool(clone)
                        end
                    else
                        if clone:FindFirstChild("Handle") then
                            local petModel = Instance.new("Model", workspace)
                            clone.Parent = petModel
                            petModel.Name = clone.Name
                            petModel.PrimaryPart = clone.Handle
                            petModel:SetPrimaryPartCFrame(HRP.CFrame + Vector3.new(math.random(-6,6), 0, math.random(-6,6)))
                            makeFollow(petModel)
                        else
                            warn("❌ No Handle on pet clone")
                        end
                    end
                    print("✅ Cloned:", clone.Name)
                else
                    warn("⚠️ Not Found:", selectedName)
                end
                task.wait(2)
            end
        end
        task.wait(1)
    end
end)
