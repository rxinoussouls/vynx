--!strict
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)
local Popover = require(script.Parent.Popover)

local Colorpicker = {}

export type ColorpickerOptions = {
	Text: string?,
	Default: Color3?,
	Transparency: number?,
	Tooltip: string?,
	Callback: ((Color3, number) -> ())?,
}

local function toHex(c: Color3): string
	return string.format("#%02X%02X%02X", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end

local function fromHex(hex: string): Color3?
	local clean = string.gsub(hex, "[#%s]", "")
	if #clean == 6 then
		local r = tonumber(string.sub(clean, 1, 2), 16)
		local g = tonumber(string.sub(clean, 3, 4), 16)
		local b = tonumber(string.sub(clean, 5, 6), 16)
		if r and g and b then
			return Color3.fromRGB(r, g, b)
		end
	end
	return nil
end

function Colorpicker.New(parent: GuiObject, id: string, options: ColorpickerOptions, registry: { [string]: any }, isEmbedded: boolean?)
	local currentColor = options.Default or Color3.fromRGB(138, 75, 255)
	local currentAlpha = options.Transparency or 0
	local callback = options.Callback or function() end
	local isOpen = false

	local frame = Elements.Create("Frame", {
		Name = id .. "_Colorpicker",
		Size = isEmbedded and UDim2.new(0, 32, 0, 18) or UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = parent,
	}) :: Frame

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	if not isEmbedded and (options.Text and options.Text ~= "") then
		local label = Elements.Create("TextLabel", {
			Size = UDim2.new(1, -40, 1, 0),
			BackgroundTransparency = 1,
			Text = options.Text or id,
			TextColor3 = Theme.Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			Parent = frame,
		}) :: TextLabel
		Theme.Register(label, "TextColor3", "Text")
	end

	local previewBtn = Elements.Create("TextButton", {
		Size = isEmbedded and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 32, 0, 18),
		AnchorPoint = isEmbedded and Vector2.zero or Vector2.new(1, 0.5),
		Position = isEmbedded and UDim2.new(0, 0, 0, 0) or UDim2.new(1, -2, 0.5, 0),
		BackgroundColor3 = currentColor,
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	}) :: TextButton
	Elements.Round(previewBtn, 4)
	local previewStroke = Elements.Stroke(previewBtn, Theme.Get("Border"), 1, 0)
	Theme.Register(previewStroke, "Color", "Border")

	-- Palette Popover Frame (Opened in ScreenGui Popover layer!)
	local popover = Elements.Create("Frame", {
		Name = id .. "_PopoverPalette",
		Size = UDim2.new(0, 180, 0, 140),
		BackgroundColor3 = Theme.Get("Secondary"),
		Visible = false,
	}) :: Frame
	Elements.Round(popover, 6)
	local popoverStroke = Elements.Stroke(popover, Theme.Get("Border"), 1, 0)
	Theme.Register(popover, "BackgroundColor3", "Secondary")
	Theme.Register(popoverStroke, "Color", "Border")
	Elements.Padding(popover, 8)

	local popoverLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = popover,
	})

	-- Hex Code input row
	local hexBox = Elements.Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = toHex(currentColor),
		TextColor3 = Theme.Get("Text"),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
		LayoutOrder = 1,
		Parent = popover,
	}) :: TextBox
	Elements.Round(hexBox, 4)
	Theme.Register(hexBox, "BackgroundColor3", "Surface")
	Theme.Register(hexBox, "TextColor3", "Text")

	-- Quick Swatches Grid
	local swatchGridFrame = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = popover,
	})

	local swatchLayout = Elements.Create("UIGridLayout", {
		CellSize = UDim2.new(0, 36, 0, 24),
		CellPadding = UDim2.new(0, 5, 0, 5),
		Parent = swatchGridFrame,
	})

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

	local colorpickerObj = {
		Frame = frame,
		Value = currentColor,
		Transparency = currentAlpha,
		Callback = callback,
		SetValue = function(self: any, newCol: Color3, newAlpha: number?)
			self.Value = newCol
			if newAlpha ~= nil then
				self.Transparency = newAlpha
			end
			previewBtn.BackgroundColor3 = newCol
			hexBox.Text = toHex(newCol)
			task.spawn(self.Callback, newCol, self.Transparency)
		end,
	}

	for _, col in ipairs(swatches) do
		local sBtn = Elements.Create("TextButton", {
			BackgroundColor3 = col,
			Text = "",
			AutoButtonColor = false,
			Parent = swatchGridFrame,
		}) :: TextButton
		Elements.Round(sBtn, 4)
		Elements.Stroke(sBtn, Color3.fromRGB(30, 30, 40), 1, 0)

		sBtn.MouseButton1Click:Connect(function()
			colorpickerObj:SetValue(col)
		end)
	end

	hexBox.FocusLost:Connect(function()
		local parsed = fromHex(hexBox.Text)
		if parsed then
			colorpickerObj:SetValue(parsed)
		else
			hexBox.Text = toHex(colorpickerObj.Value)
		end
	end)

	previewBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			hexBox.Text = toHex(colorpickerObj.Value)
			Popover.Open(popover, previewBtn, function()
				isOpen = false
			end)
		else
			Popover.Close()
		end
	end)

	frame.Destroying:Connect(function()
		popover:Destroy()
	end)

	registry[id] = colorpickerObj
	return colorpickerObj
end

return Colorpicker
