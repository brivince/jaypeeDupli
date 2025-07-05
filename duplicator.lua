-- Pet Duplicator UI with Local Inventory
-- Author: brivince & ChatGPT

local player = game:GetService("Players").LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Clean up old UI
if PlayerGui:FindFirstChild("PetDuplicatorUI") then
	PlayerGui.PetDuplicatorUI:Destroy()
end

-- Inventory Table
local playerInventory = {}

-- UI Container
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "PetDuplicatorUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 240)
frame.Position = UDim2.new(0.5, -150, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🐾 Pet Duplicator"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextScaled = true

-- Dropdown
local petDropdown = Instance.new("TextButton", frame)
petDropdown.Position = UDim2.new(0.1, 0, 0, 50)
petDropdown.Size = UDim2.new(0.8, 0, 0, 35)
petDropdown.Text = "Choose Pet"
petDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
petDropdown.TextColor3 = Color3.new(1, 1, 1)
petDropdown.Font = Enum.Font.Gotham
petDropdown.TextScaled = true

-- Quantity Box
local quantityBox = Instance.new("TextBox", frame)
quantityBox.Position = UDim2.new(0.1, 0, 0, 100)
quantityBox.Size = UDim2.new(0.8, 0, 0, 35)
quantityBox.Text = "1"
quantityBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
quantityBox.TextColor3 = Color3.new(1, 1, 1)
quantityBox.Font = Enum.Font.Gotham
quantityBox.TextScaled = true
quantityBox.ClearTextOnFocus = false

-- Duplicate Button
local duplicateButton = Instance.new("TextButton", frame)
duplicateButton.Position = UDim2.new(0.1, 0, 0, 150)
duplicateButton.Size = UDim2.new(0.8, 0, 0, 35)
duplicateButton.Text = "Duplicate"
duplicateButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
duplicateButton.TextColor3 = Color3.new(1, 1, 1)
duplicateButton.Font = Enum.Font.GothamBold
duplicateButton.TextScaled = true

-- View Inventory Button
local inventoryButton = Instance.new("TextButton", frame)
inventoryButton.Position = UDim2.new(0.1, 0, 0, 195)
inventoryButton.Size = UDim2.new(0.8, 0, 0, 30)
inventoryButton.Text = "View Inventory"
inventoryButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
inventoryButton.TextColor3 = Color3.new(1, 1, 1)
inventoryButton.Font = Enum.Font.Gotham
inventoryButton.TextScaled = true

-- Pet List
local selectedPet = nil
local pets = {"Snail", "Giant Ant", "Capybara", "Macaw", "Grey Mouse", "Octopus", "Red Fox"}

-- Dropdown menu
petDropdown.MouseButton1Click:Connect(function()
	local menu = Instance.new("Frame", screenGui)
	menu.Size = UDim2.new(0, 200, 0, #pets * 30)
	menu.Position = UDim2.new(0.5, -100, 0.5, -50)
	menu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	menu.ZIndex = 5

	for i, pet in ipairs(pets) do
		local btn = Instance.new("TextButton", menu)
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
		btn.Text = pet
		btn.Font = Enum.Font.Gotham
		btn.TextScaled = true
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		btn.MouseButton1Click:Connect(function()
			selectedPet = pet
			petDropdown.Text = pet
			menu:Destroy()
		end)
	end
end)

-- Duplicate logic
duplicateButton.MouseButton1Click:Connect(function()
	if selectedPet and tonumber(quantityBox.Text) then
		local amount = tonumber(quantityBox.Text)

		playerInventory[selectedPet] = (playerInventory[selectedPet] or 0) + amount

		for i = 1, amount do
			local pet = Instance.new("Part")
			pet.Name = selectedPet
			pet.Shape = Enum.PartType.Ball
			pet.Size = Vector3.new(1.5, 1.5, 1.5)
			pet.BrickColor = BrickColor.Random()
			pet.Anchored = false
			pet.CanCollide = false
			pet.Position = player.Character.HumanoidRootPart.Position + Vector3.new(i * 2, 3, 0)
			pet.Parent = workspace
		end

		print("✅ Added to inventory:", selectedPet, "Total:", playerInventory[selectedPet])
	end
end)

-- Show inventory in output
inventoryButton.MouseButton1Click:Connect(function()
	print("📦 Your Inventory:")
	for petName, count in pairs(playerInventory) do
		print("• " .. petName .. " x" .. count)
	end
end)
