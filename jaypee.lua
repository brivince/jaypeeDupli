--[[ 
🌱 Grow a Garden - Hatch Reveal GUI (Solara V3)
👀 Shows what pet is inside each growing egg before hatching
✅ Works with Solara V3 executor
]]

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Load Solara GUI library
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/3xploits7/Solara/main/Lib.lua"))()
local win = lib:Window("🥚 Hatch Reveal", Color3.fromRGB(255, 180, 70), Enum.KeyCode.RightControl)
local tab = win:Tab("🔍 Growing Eggs")

-- UI label to display egg contents
local box = tab:Label("Scanning...")

-- Function to find all growing eggs and check their future pet
local function getEggInfo()
    local results = {}

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("egg") then
            local petModel = nil
            local petName = nil

            -- Try to find a hidden pet model inside
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("Model") then
                    petModel = child
                    break
                end
            end

            -- Try to find a StringValue or ObjectValue with pet name
            if not petModel then
                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("StringValue") and child.Name:lower():find("pet") then
                        petName = child.Value
                        break
                    end
                end
            end

            -- Determine what to show
            local result = ""
            if petModel then
                result = "🥚 " .. obj.Name .. " → " .. petModel.Name
            elseif petName then
                result = "🥚 " .. obj.Name .. " → " .. petName
            else
                result = "🥚 " .. obj.Name .. " → ??? (Pet hidden)"
            end

            table.insert(results, result)
        end
    end

    return results
end

-- Auto refresh every 2 seconds
task.spawn(function()
    while task.wait(2) do
        local hatchList = getEggInfo()
        if #hatchList > 0 then
            box:Set("🔍 Hatch Results:\n" .. table.concat(hatchList, "\n"))
        else
            box:Set("🔍 No growing eggs found.")
        end
    end
end)
