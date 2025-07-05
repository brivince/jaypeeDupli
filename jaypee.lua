-- Hatch Reveal Debug Script
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

Workspace.DescendantAdded:Connect(function(child)
    if string.lower(child.Name):find("hatch") then
        StarterGui:SetCore("SendNotification", {
            Title = "🐣 Hatch Detected",
            Text = child.Name,
            Duration = 4
        })
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Hatch Tracker",
    Text = "Listening for egg hatches...",
    Duration = 5
})
