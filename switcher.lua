-- KRNL Avatar Changer – HumanoidDescription Edition
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AvatarChangerGUI"

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0,150,0,40)
ToggleButton.Position = UDim2.new(0,20,0,20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Text = "Avatar Changer"
ToggleButton.BorderSizePixel = 0

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,300,0,500)
Frame.Position = UDim2.new(0,20,0,70)
Frame.BackgroundColor3 = Color3.fromRGB(30,0,0)
Frame.Visible = false

-- Draggable
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		Frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
	end
end)
ToggleButton.MouseButton1Click:Connect(function() Frame.Visible = not Frame.Visible end)

-- Layout
local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0,10)

-- === Store "saved outfits" locally ===
local savedOutfits = {}

-- Add current avatar as first outfit
local function addCurrentAvatarAsOutfit(name)
	local desc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
	table.insert(savedOutfits, {name = name or "Current Avatar", desc = desc})
end

addCurrentAvatarAsOutfit("My Current Avatar") -- start with one

-- Create outfit buttons with previews
local function createOutfitButton(outfit)
	local buttonFrame = Instance.new("Frame", Frame)
	buttonFrame.Size = UDim2.new(1, -10, 0, 100)
	buttonFrame.BackgroundColor3 = Color3.fromRGB(50,0,0)
	buttonFrame.BorderSizePixel = 0

	local button = Instance.new("TextButton", buttonFrame)
	button.Size = UDim2.new(0.6, -10, 1, -10)
	button.Position = UDim2.new(0,5,0,5)
	button.BackgroundColor3 = Color3.fromRGB(150,0,0)
	button.BorderSizePixel = 0
	button.TextColor3 = Color3.fromRGB(255,255,255)
	button.Text = outfit.name

	local viewport = Instance.new("ViewportFrame", buttonFrame)
	viewport.Size = UDim2.new(0.35, -10, 1, -10)
	viewport.Position = UDim2.new(0.65,5,0,5)
	viewport.BackgroundColor3 = Color3.fromRGB(0,0,0)
	viewport.BorderSizePixel = 0

	local dummy = Instance.new("Model")
	dummy.Name = "PreviewDummy"
	dummy.Parent = viewport

	local hrp = Instance.new("Part")
	hrp.Size = Vector3.new(2,2,1)
	hrp.Anchored = true
	hrp.Parent = dummy

	-- Apply HumanoidDescription
	pcall(function()
		outfit.desc:ApplyTo(dummy)
	end)

	local cam = Instance.new("Camera")
	cam.CFrame = CFrame.new(Vector3.new(0,2,5), Vector3.new(0,2,0))
	viewport.CurrentCamera = cam

	-- Swap outfit on click
	button.MouseButton1Click:Connect(function()
		outfit.desc:ApplyTo(player)
	end)
end

-- Render all saved outfits
for _, outfit in ipairs(savedOutfits) do
	createOutfitButton(outfit)
end

-- Add new outfit mid-game example (just a test)
-- addCurrentAvatarAsOutfit("New Outfit Name")
-- createOutfitButton(savedOutfits[#savedOutfits])
