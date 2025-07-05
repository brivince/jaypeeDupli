-- Grow a Garden Hatch Reveal Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- Optional: clear console if you're using output
pcall(function()
    rconsoleclear()
    rconsolename("Hatch Logger")
end)

-- Listen to new hatches inside workspace or effects
local function onHatch(child)
    if typeof(child) == "Instance" and child:IsA("Model") or child:IsA("Part") then
        local name = child.Name:lower()

        if name:find("seed") or name:find("bug") or name:find("pet") or name:find("egg") then
            -- Send popup
            StarterGui:SetCore("SendNotification", {
                Title = "🎉 Hatch Detected!",
                Text = "You got: " .. child.Name,
                Duration = 4
            })

            -- Optional console log
            pcall(function()
                rconsoleprint("[HATCH] --> " .. child.Name .. "\n")
            end)
        end
    end
end

-- Watch workspace for new things
game:GetService("Workspace").DescendantAdded:Connect(onHatch)

-- Confirm script loaded
StarterGui:SetCore("SendNotification", {
    Title = "Jaypee Hatch Logger",
    Text = "Listening for new hatches...",
    Duration = 5
})
