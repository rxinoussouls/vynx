local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)
local Popover = require(script.Parent.Popover)

local Colorpicker = {}

local function toHex(c)
	return string.format("#%02X%02X%02X", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end

local function fromHex(hex)
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

function Colorpicker.New(parent, id, options, registry, isEmbedded)
	options = options or {}
	local currentColor = options.Default or Color3.fromRGB(10, 132, 255)
	local currentAlpha = options.Transparency or 0
	local callback = options.Callback or function() end
	local isOpen = false

	local frame = Elements.Create("Frame", {
		Name = id .. "_Colorpicker",
		Size = isEmbedded and UDim2.fromOffset(28, 20) or UDim2.new(0, 0, 0, 26),
		AutomaticSize = isEmbedded and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	local previewBtn = Elements.Create("TextButton", {
		Name = "PreviewSwatch",
		Size = UDim2.fromOffset(28, 20),
		BackgroundColor3 = currentColor,
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
	Elements.Round(previewBtn, 5)
	local previewStroke = Elements.Stroke(previewBtn, Theme.Get("Hairline"), 1, 0)
	Theme.Register(previewStroke, "Color", "Hairline")

	-- Popover Palette Card
	local popover = Elements.Create("Frame", {
		Name = id .. "_PopoverPalette",
		Size = UDim2.fromOffset(200, 150),
		BackgroundColor3 = Theme.Get("FormCard"),
		Visible = false,
	})
	Elements.Round(popover, 8)
	local popoverStroke = Elements.Stroke(popover, Theme.Get("Hairline"), 1, 0)
	Theme.Register(popover, "BackgroundColor3", "FormCard")
	Theme.Register(popoverStroke, "Color", "Hairline")
	Elements.Padding(popover, 8)
	Elements.Shadow(popover, 2, 8, 0.45)

	local popoverLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = popover,
	})

	-- Hex Code Box
	local hexBox = Elements.Create("TextBox", {
		Name = "HexInput",
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = Theme.Get("ControlFill"),
		Text = toHex(currentColor),
		TextColor3 = Theme.Get("Text"),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
		LayoutOrder = 1,
		Parent = popover,
	})
	Elements.Round(hexBox, 4)
	Theme.Register(hexBox, "BackgroundColor3", "ControlFill")
	Theme.Register(hexBox, "TextColor3", "Text")

	-- Curated Apple Palette Swatches
	local swatchGridFrame = Elements.Create("Frame", {
		Name = "SwatchesGrid",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = popover,
	})

	local swatchLayout = Elements.Create("UIGridLayout", {
		CellSize = UDim2.fromOffset(32, 24),
		CellPadding = UDim2.fromOffset(6, 6),
		Parent = swatchGridFrame,
	})

	local appleSwatches = {
		Color3.fromRGB(10, 132, 255),  -- Blue
		Color3.fromRGB(191, 90, 242),  -- Purple
		Color3.fromRGB(255, 55, 95),   -- Pink
		Color3.fromRGB(255, 69, 58),   -- Red
		Color3.fromRGB(255, 159, 10),  -- Orange
		Color3.fromRGB(255, 214, 10),  -- Yellow
		Color3.fromRGB(48, 209, 88),   -- Green
		Color3.fromRGB(152, 152, 159), -- Graphite
		Color3.fromRGB(255, 255, 255), -- White
		Color3.fromRGB(28, 28, 30),    -- Dark Window
	}

	local colorpickerObj = {
		Frame = frame,
		Value = currentColor,
		Transparency = currentAlpha,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newCol, newAlpha)
			self.Value = newCol
			if newAlpha ~= nil then
				self.Transparency = newAlpha
			end
			previewBtn.BackgroundColor3 = newCol
			hexBox.Text = toHex(newCol)
			task.spawn(self.Callback, newCol, self.Transparency)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newCol, self.Transparency)
			end
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
		end,
	}

	for _, col in ipairs(appleSwatches) do
		local sBtn = Elements.Create("TextButton", {
			BackgroundColor3 = col,
			Text = "",
			AutoButtonColor = false,
			Parent = swatchGridFrame,
		})
		Elements.Round(sBtn, 4)
		local sStroke = Elements.Stroke(sBtn, Theme.Get("Hairline"), 1, 0)
		Theme.Register(sStroke, "Color", "Hairline")

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

	if registry then
		registry[id] = colorpickerObj
	end

	return colorpickerObj
end

return Colorpicker
