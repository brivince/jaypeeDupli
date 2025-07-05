-- Hatch Reveal UI for Grow a Garden (Bug, Paradise, Mythical Eggs)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove old UI if exists
if PlayerGui:FindFirstChild("EggHatchViewer") then
    PlayerGui:FindFirstChild("EggHatchViewer"):Destroy()
end

-- Hatch results
local hatchTable = {
    ["Bug Egg"] = {
        "Snail", "Giant Ant", "Caterpillar", "Praying Mantis", "Dragonfly"
    },
    ["Paradise Egg"] = {
        "Ostrich", "Peacock", "Capybara", "Macaw", "Octopus"
    },
    ["Mythical Egg"] = {
        "Grey Mouse", "Brown Mouse", "Squirrel", "Giant Red Ant", "Red Fox"
    }
}

-- Create UI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "EggHatchViewer"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 350, 0, 250)
frame.Position = UDim2.new(0.5, -175, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🥚 Egg Hatch Viewer"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local dropdownLabel = Instance.new("TextLabel", frame)
dropdownLabel.Position = UDim2.new(0, 0, 0, 50)
dropdownLabel.Size = UDim2.new(1, 0, 0, 30)
dropdownLabel.BackgroundTransparency = 1
dropdownLabel.Text = "Select an Egg Type:"
dropdownLabel.TextColor3 = Color3.new(1, 1, 1)
dropdownLabel.Font = Enum.Font.Gotham
dropdownLabel.TextScaled = true

local eggDropdown = Instance.new("TextButton", frame)
eggDropdown.Position = UDim2.new(0.1, 0, 0, 85)
eggDropdown.Size = UDim2.new(0.8, 0, 0, 35)
eggDropdown.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
eggDropdown.Text = "Click to choose"
eggDropdown.TextColor3 = Color3.new(1, 1, 1)
eggDropdown.Font = Enum.Font.GothamBold
eggDropdown.TextScaled = true

local resultLabel = Instance.new("TextLabel", frame)
resultLabel.Position = UDim2.new(0.05, 0, 0, 130)
resultLabel.Size = UDim2.new(0.9, 0, 1, -140)
resultLabel.BackgroundTransparency = 1
resultLabel.Text = "Hatch results will appear here"
resultLabel.TextColor3 = Color3.new(1, 1, 1)
resultLabel.TextScaled = true
resultLabel.TextWrapped = true
resultLabel.Font = Enum.Font.Gotham

-- Egg selector logic
local eggList = {"Bug Egg", "Paradise Egg", "Mythical Egg"}

eggDropdown.MouseButton1Click:Connect(function()
    local menu = Instance.new("Frame")
    menu.Position = UDim2.new(0, eggDropdown.AbsolutePosition.X, 0, eggDropdown.AbsolutePosition.Y + 35)
    menu.Size = UDim2.new(0, eggDropdown.AbsoluteSize.X, 0, #eggList * 30)
    menu.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    menu.Parent = screenGui
    menu.ZIndex = 10

    for i, egg in ipairs(eggList) do
        local option = Instance.new("TextButton")
        option.Size = UDim2.new(1, 0, 0, 30)
        option.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        option.Text = egg
        option.TextScaled = true
        option.TextColor3 = Color3.new(1, 1, 1)
        option.Font = Enum.Font.Gotham
        option.BackgroundColor3 = Color3.fromRGB(255, 140, 140)
        option.Parent = menu
        option.ZIndex = 11

        option.MouseButton1Click:Connect(function()
            eggDropdown.Text = egg
            local pets = hatchTable[egg]
            resultLabel.Text = "You may hatch:\n- " .. table.concat(pets, "\n- ")
            menu:Destroy()
        end)
    end
end)
