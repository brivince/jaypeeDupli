-- Pet Duplicator with UI, server logic, and follower (for Solara injection)
-- Author: brivince & ChatGPT

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create RemoteEvent if missing
if not ReplicatedStorage:FindFirstChild("DuplicatePet") then
    local remote = Instance.new("RemoteEvent")
    remote.Name = "DuplicatePet"
    remote.Parent = ReplicatedStorage
end

-- Inject UI
spawn(function()
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")

    if PlayerGui:FindFirstChild("PetDuplicatorUI") then
        PlayerGui.PetDuplicatorUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui", PlayerGui)
    screenGui.Name = "PetDuplicatorUI"
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "🐾 Pet Duplicator"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    title.TextScaled = true

    local petDropdown = Instance.new("TextButton", frame)
    petDropdown.Position = UDim2.new(0.1, 0, 0, 50)
    petDropdown.Size = UDim2.new(0.8, 0, 0, 35)
    petDropdown.Text = "Choose a Pet"
    petDropdown.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    petDropdown.TextColor3 = Color3.new(1, 1, 1)
    petDropdown.Font = Enum.Font.Gotham
    petDropdown.TextScaled = true

    local quantityBox = Instance.new("TextBox", frame)
    quantityBox.Position = UDim2.new(0.1, 0, 0, 100)
    quantityBox.Size = UDim2.new(0.8, 0, 0, 35)
    quantityBox.Text = "1"
    quantityBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    quantityBox.TextColor3 = Color3.new(1, 1, 1)
    quantityBox.Font = Enum.Font.Gotham
    quantityBox.TextScaled = true
    quantityBox.ClearTextOnFocus = false

    local duplicateButton = Instance.new("TextButton", frame)
    duplicateButton.Position = UDim2.new(0.1, 0, 0, 150)
    duplicateButton.Size = UDim2.new(0.8, 0, 0, 35)
    duplicateButton.Text = "Duplicate"
    duplicateButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    duplicateButton.TextColor3 = Color3.new(1, 1, 1)
    duplicateButton.Font = Enum.Font.GothamBold
    duplicateButton.TextScaled = true

    local selectedPet = nil
    local pets = {"Snail", "Dragonfly", "Capybara", "Red Fox", "Grey Mouse"}

    petDropdown.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame", screenGui)
        menu.Size = UDim2.new(0, 200, 0, #pets * 30)
        menu.Position = UDim2.new(0.5, -100, 0.5, -50)
        menu.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        menu.ZIndex = 5

        for i, pet in ipairs(pets) do
            local btn = Instance.new("TextButton", menu)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*30)
            btn.Text = pet
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            btn.MouseButton1Click:Connect(function()
                selectedPet = pet
                petDropdown.Text = pet
                menu:Destroy()
            end)
        end
    end)

    duplicateButton.MouseButton1Click:Connect(function()
        if selectedPet and tonumber(quantityBox.Text) then
            ReplicatedStorage:WaitForChild("DuplicatePet"):FireServer(selectedPet, tonumber(quantityBox.Text))
        end
    end)
end)

-- Server-side logic for Solara (runs if allowed)
if not game:GetService("RunService"):IsClient() then
    local petInventory = {}

    local function createPetModel(name)
        local part = Instance.new("Part")
        part.Name = name
        part.Size = Vector3.new(1.5, 1.5, 1.5)
        part.Shape = Enum.PartType.Ball
        part.BrickColor = BrickColor.Random()
        part.Anchored = false
        part.CanCollide = false
        return part
    end

    game:GetService("ReplicatedStorage").DuplicatePet.OnServerEvent:Connect(function(player, petName, quantity)
        petInventory[player.UserId] = petInventory[player.UserId] or {}
        for i = 1, quantity do
            table.insert(petInventory[player.UserId], petName)

            local pet = createPetModel(petName)
            pet.Parent = workspace

            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local offset = Vector3.new(i * 2, 0, -3)
                game:GetService("RunService").Heartbeat:Connect(function()
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        pet.Position = char.HumanoidRootPart.Position + offset + Vector3.new(0, math.sin(tick() + i) * 0.5, 0)
                    end
                end)
            end
        end
    end)
end
