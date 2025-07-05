-- Grow a Garden Hatch Reveal - All Egg Types
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- Show popup when a new seed/pet/egg appears in workspace
Workspace.DescendantAdded:Connect(function(child)
    if typeof(child) == "Instance" and (child:IsA("Model") or child:IsA("Part")) then
        local name = child.Name:lower()

        -- Check if the name includes keywords like egg, seed, pet, or bug
        if name:find("egg") or name:find("seed") or name:find("pet") or name:find("bug") then
            StarterGui:SetCore("SendNotification", {
                Title = "🎉 Hatch Detected!",
                Text = "You got: " .. child.Name,
                Duration = 5
            })

            -- Optional console log
            pcall(function()
                rconsoleprint("[HATCH] --> " .. child.Name .. "\n")
            end)
        end
    end
end)

-- Confirmation message
StarterGui:SetCore("SendNotification", {
    Title = "Jaypee Hatch Logger",
    Text = "Now tracking all egg hatches...",
    Duration = 4
})
