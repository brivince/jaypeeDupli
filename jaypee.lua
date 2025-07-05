-- Debug Notification + UI Test
local success, err = pcall(function()
    -- Notification to confirm script is loaded
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Jaypee UI",
        Text = "Script Loaded ✅",
        Duration = 5
    })

    -- Create UI ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JaypeeUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    -- Create red draggable frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    -- Add a label to confirm it's visible
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 40)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "✅ UI Visible"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
end)

-- Error catcher
if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error ❌",
        Text = tostring(err),
        Duration = 10
    })
end
