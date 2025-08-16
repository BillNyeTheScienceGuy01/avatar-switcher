-- KRNL Avatar Changer 2.0 Ultra C00LKIDD
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- === AUTO USERID ===
local userId = player.UserId

-- === GUI SETUP ===
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AvatarChangerGUI"

-- Toggle Button
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0,150,0,40)
ToggleButton.Position = UDim2.new(0,20,0,20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Text = "Avatar Changer"
ToggleButton.BorderSizePixel = 0

-- Main Frame
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 500)
Frame.Position = UDim2.new(0, 20, 0, 70)
Frame.BackgroundColor3 = Color3.fromRGB(30,0,0)
Frame.BorderSizePixel = 0
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
ToggleButton.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
end)

-- Layout
local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0,10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Search Bar
local SearchBox = Instance.new("TextBox", Frame)
SearchBox.Size = UDim2.new(1, -10, 0, 30)
SearchBox.Position = UDim2.new(0,5,0,5)
SearchBox.BackgroundColor3 = Color3.fromRGB(50,0,0)
SearchBox.TextColor3 = Color3.fromRGB(255,255,255)
SearchBox.PlaceholderText = "Search outfits..."
SearchBox.ClearTextOnFocus = false

-- === FETCH SAVED OUTFITS VIA ROBLOX API ===
local function fetchSavedOutfits()
	local url = "https://avatar.roblox.com/v1/users/"..userId.."/outfits"
	local success, response = pcall(function()
		return HttpService:GetAsync(url, true)
	end)
	if success then
		local data = HttpService:JSONDecode(response)
		return data.data or {}
	else
		warn("Failed to fetch outfits")
		return {}
	end
end

local outfits = fetchSavedOutfits()
local buttons = {}

-- === CREATE BUTTONS + PREVIEWS ===
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
	button.Text = outfit.name or "Outfit"

	local viewport = Instance.new("ViewportFrame", buttonFrame)
	viewport.Size = UDim2.new(0.35, -10, 1, -10)
	viewport.Position = UDim2.new(0.65, 5, 0, 5)
	viewport.BackgroundColor3 = Color3.fromRGB(0,0,0)
	viewport.BorderSizePixel = 0

	local dummy = Instance.new("Model")
	dummy.Name = "PreviewDummy"
	dummy.Parent = viewport

	local hrp = Instance.new("Part")
	hrp.Size = Vector3.new(2,2,1)
	hrp.Anchored = true
	hrp.Parent = dummy

	-- Apply outfit
	pcall(function()
		local desc = Players:GetHumanoidDescriptionFromUserId(userId)
		desc:ApplyTo(dummy)
	end)

	-- Camera
	local cam = Instance.new("Camera")
	cam.CFrame = CFrame.new(Vector3.new(0,2,5), Vector3.new(0,2,0))
	viewport.CurrentCamera = cam

	-- Swap on click
	button.MouseButton1Click:Connect(function()
		local desc = Players:GetHumanoidDescriptionFromUserId(userId)
		desc:ApplyTo(player)
	end)

	-- Hover animation (simple up/down)
	buttonFrame.MouseEnter:Connect(function()
		RunService:BindToRenderStep("HoverAnim"..outfit.id, Enum.RenderPriority.Camera.Value, function()
			hrp.CFrame = hrp.CFrame * CFrame.new(0, 0.02*math.sin(tick()*10), 0)
		end)
	end)
	buttonFrame.MouseLeave:Connect(function()
		RunService:UnbindFromRenderStep("HoverAnim"..outfit.id)
	end)

	table.insert(buttons, {frame = buttonFrame, outfit = outfit})
end

for _, outfit in ipairs(outfits) do
	createOutfitButton(outfit)
end

-- === SEARCH FILTER ===
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local query = SearchBox.Text:lower()
	for _, btn in ipairs(buttons) do
		if btn.outfit.name:lower():find(query) then
			btn.frame.Visible = true
		else
			btn.frame.Visible = false
		end
	end
end)
