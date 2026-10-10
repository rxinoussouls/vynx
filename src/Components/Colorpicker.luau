--!strict
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)

local Colorpicker = {}

export type ColorpickerOptions = {
	Text: string,
	Default: Color3?,
	Transparency: number?,
	Callback: ((Color3, number) -> ())?,
}

function Colorpicker.New(parent: GuiObject, id: string, options: ColorpickerOptions, registry: { [string]: any })
	local currentColor = options.Default or Color3.fromRGB(138, 75, 255)
	local currentAlpha = options.Transparency or 0
	local callback = options.Callback or function() end
	local isOpen = false

	local frame = Elements.Create("Frame", {
		Name = id .. "_Colorpicker",
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		ZIndex = 6,
		Parent = parent,
	}) :: Frame

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Text or id,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		ZIndex = 6,
		Parent = frame,
	}) :: TextLabel
	Theme.Register(label, "TextColor3", "Text")

	local previewBtn = Elements.Create("TextButton", {
		Size = UDim2.new(0, 32, 0, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -2, 0.5, 0),
		BackgroundColor3 = currentColor,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 6,
		Parent = frame,
	}) :: TextButton
	Elements.Round(previewBtn, 4)
	local previewStroke = Elements.Stroke(previewBtn, Theme.Get("Border"), 1, 0)
	Theme.Register(previewStroke, "Color", "Border")

	-- Palette Popover
	local popover = Elements.Create("Frame", {
		Size = UDim2.new(0, 160, 0, 110),
		Position = UDim2.new(1, -160, 1, 4),
		BackgroundColor3 = Theme.Get("Secondary"),
		Visible = false,
		ZIndex = 30,
		Parent = previewBtn,
	}) :: Frame
	Elements.Round(popover, 6)
	local popoverStroke = Elements.Stroke(popover, Theme.Get("Border"), 1, 0)
	Theme.Register(popover, "BackgroundColor3", "Secondary")
	Theme.Register(popoverStroke, "Color", "Border")
	Elements.Padding(popover, 8)

	-- Swatches
	local swatches = {
		Color3.fromRGB(255, 75, 75),
		Color3.fromRGB(255, 150, 50),
		Color3.fromRGB(255, 220, 50),
		Color3.fromRGB(60, 220, 120),
		Color3.fromRGB(50, 180, 255),
		Color3.fromRGB(138, 75, 255),
		Color3.fromRGB(255, 100, 200),
		Color3.fromRGB(255, 255, 255),
	}

	local swatchGrid = Elements.Create("UIGridLayout", {
		CellSize = UDim2.new(0, 32, 0, 24),
		CellPadding = UDim2.new(0, 5, 0, 5),
		Parent = popover,
	})

	local colorpickerObj = {
		Value = currentColor,
		Transparency = currentAlpha,
		Callback = callback,
		SetValue = function(self: any, newCol: Color3, newAlpha: number?)
			self.Value = newCol
			if newAlpha then
				self.Transparency = newAlpha
			end
			previewBtn.BackgroundColor3 = newCol
			task.spawn(self.Callback, newCol, self.Transparency)
		end,
	}

	for _, col in ipairs(swatches) do
		local sBtn = Elements.Create("TextButton", {
			BackgroundColor3 = col,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 31,
			Parent = popover,
		}) :: TextButton
		Elements.Round(sBtn, 4)
		Elements.Stroke(sBtn, Color3.fromRGB(30, 30, 40), 1, 0)
		sBtn.MouseButton1Click:Connect(function()
			colorpickerObj:SetValue(col)
		end)
	end

	previewBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		popover.Visible = isOpen
		frame.ZIndex = isOpen and 50 or 6
	end)

	registry[id] = colorpickerObj
	return colorpickerObj
end

return Colorpicker
