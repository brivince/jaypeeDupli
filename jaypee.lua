-- Grow a Garden - Hatch Reveal (Local Garden Watcher)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

-- Notify that script is loaded
StarterGui:SetCore("SendNotification", {
    Title = "Jaypee Hatch Watcher",
    Text = "Locating your garden...",
    Duration = 4
})

-- Utility to detect hatch-related names
local function isHatchItem(name)
    name = name:lower()
    return name:find("egg") or name:find("seed") or name:find("pet") or name:find("bug")
end

-- Try to find the local player's garden plot
local function getPlayerPlot()
    local plots = Workspace:FindFirstChild("GardenPlots")
    if not plots then return nil end

    for _, plot in pairs(plots:GetChildren()) do
        if plot:IsA("Model") and plot.Name:find(LocalPlayer.Name) then
            return plot
        end
    end
    return nil
end

-- Hook new children added to your plot
local function trackPlot(plot)
    StarterGui:SetCore("SendNotification", {
        Title = "🎯 Hatch Watch Enabled",
        Text = "Watching: " .. plot.Name,
        Duration = 4
    })

    plot.DescendantAdded:Connect(function(descendant)
        if isHatchItem(descendant.Name) then
            StarterGui:SetCore("SendNotification", {
                Title = "🎉 Hatch Detected!",
                Text = "You got: " .. descendant.Name,
                Duration = 5
            })

            -- Optional console
            pcall(function()
                rconsoleprint("[HATCH] --> " .. descendant.Name .. "\n")
            end)
        end
    end)
end

-- Wait until plot is available
local function waitForPlotAndTrack()
    local plot
    while not plot do
        plot = getPlayerPlot()
        task.wait(1)
    end
    trackPlot(plot)
end

waitForPlotAndTrack()
