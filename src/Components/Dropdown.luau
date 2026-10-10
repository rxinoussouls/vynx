local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)
local Popover = require(script.Parent.Popover)

local Dropdown = {}

function Dropdown.New(parent, id, options, registry, isRow)
	options = options or {}
	local values = options.Values or {}
	local isMulti = options.Multi or false
	local callback = options.Callback or function() end
	local isOpen = false

	local currentValue
	if isMulti then
		currentValue = {}
		if typeof(options.Default) == "table" then
			for _, v in ipairs(options.Default) do
				currentValue[v] = true
			end
		end
	else
		currentValue = options.Default or values[1] or ""
	end

	local container = nil
	local box = nil

	if isRow then
		container = Elements.Create("Frame", {
			Name = id .. "_DropdownHolder",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Parent = parent,
		})

		box = Elements.Create("TextButton", {
			Name = "SelectButton",
			Size = UDim2.new(0, 160, 0, 28),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Theme.Get("ControlFill"),
			Text = "",
			AutoButtonColor = false,
			Parent = container,
		})
	else
		container = Elements.Create("Frame", {
			Name = id .. "_Dropdown",
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundTransparency = 1,
			Parent = parent,
		})

		local label = Elements.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Text = options.Text or id,
			TextColor3 = Theme.Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = Theme.Typography.RowTitle.Size,
			Font = Theme.Typography.RowTitle.Font,
			Parent = container,
		})
		Theme.Register(label, "TextColor3", "Text")

		box = Elements.Create("TextButton", {
			Name = "SelectButton",
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 0, 22),
			BackgroundColor3 = Theme.Get("ControlFill"),
			Text = "",
			AutoButtonColor = false,
			Parent = container,
		})
	end

	Elements.Round(box, 6)
	local boxStroke = Elements.Stroke(box, Theme.Get("Hairline"), 1, 0)
	Theme.Register(box, "BackgroundColor3", "ControlFill")
	Theme.Register(boxStroke, "Color", "Hairline")

	if options.Tooltip then
		Tooltip.Attach(container, options.Tooltip)
	end

	local valLabel = Elements.Create("TextLabel", {
		Name = "ValueLabel",
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = Theme.Typography.Subtitle.Size,
		Font = Theme.Typography.Subtitle.Font,
		Parent = box,
	})
	Theme.Register(valLabel, "TextColor3", "Text")

	local arrow = Elements.Create("TextLabel", {
		Name = "Chevron",
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -22, 0, 0),
		BackgroundTransparency = 1,
		Text = "⌄",
		TextColor3 = Theme.Get("SecondaryText"),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Parent = box,
	})
	Theme.Register(arrow, "TextColor3", "SecondaryText")

	-- Popover List Floating Card
	local listFrame = Elements.Create("Frame", {
		Name = id .. "_PopoverList",
		Size = UDim2.new(0, 200, 0, 180),
		BackgroundColor3 = Theme.Get("FormCard"),
		Visible = false,
	})
	Elements.Round(listFrame, 8)
	local listStroke = Elements.Stroke(listFrame, Theme.Get("Hairline"), 1, 0)
	Theme.Register(listFrame, "BackgroundColor3", "FormCard")
	Theme.Register(listStroke, "Color", "Hairline")
	Elements.Padding(listFrame, 6)

	-- Procedural shadow for popup
	Elements.Shadow(listFrame, 2, 8, 0.45)

	local listLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = listFrame,
	})

	local searchBox = Elements.Create("TextBox", {
		Name = "SearchBox",
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = Theme.Get("ControlFill"),
		PlaceholderText = "Search...",
		PlaceholderColor3 = Theme.Get("TertiaryText"),
		TextColor3 = Theme.Get("Text"),
		Text = "",
		TextSize = 12,
		Font = Theme.Typography.Subtitle.Font,
		Visible = #values > 8,
		LayoutOrder = 1,
		Parent = listFrame,
	})
	Elements.Round(searchBox, 4)
	Theme.Register(searchBox, "BackgroundColor3", "ControlFill")
	Theme.Register(searchBox, "TextColor3", "Text")
	Theme.Register(searchBox, "PlaceholderColor3", "TertiaryText")

	local scrollContainer = Elements.Create("ScrollingFrame", {
		Name = "ItemsScroll",
		Size = UDim2.new(1, 0, 1, #values > 8 and -30 or 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Get("Accent"),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = listFrame,
	})

	local itemsLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = scrollContainer,
	})

	local function getDisplayText()
		if isMulti then
			local active = {}
			for item, selected in pairs(currentValue) do
				if selected then
					table.insert(active, tostring(item))
				end
			end
			return #active > 0 and table.concat(active, ", ") or "None"
		else
			return tostring(currentValue)
		end
	end

	valLabel.Text = getDisplayText()

	local dropdownObj = {
		Value = currentValue,
		Values = values,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newVal)
			self.Value = newVal
			currentValue = newVal
			valLabel.Text = getDisplayText()
			task.spawn(self.Callback, newVal)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newVal)
			end
		end,
		SetValues = function(self, newValues)
			self.Values = newValues
			values = newValues
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
		end,
	}

	local function refreshItems(filter)
		for _, child in ipairs(scrollContainer:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local query = filter and string.lower(filter) or ""
		for _, itemVal in ipairs(dropdownObj.Values) do
			if query == "" or string.find(string.lower(itemVal), query, 1, true) then
				local isSelected = isMulti and (currentValue[itemVal] == true) or (currentValue == itemVal)
				local itemBtn = Elements.Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundColor3 = isSelected and Theme.Get("Accent") or Theme.Get("ControlFill"),
					BackgroundTransparency = isSelected and 0 or 1,
					Text = (isSelected and "  ✓ " or "    ") .. itemVal,
					TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Theme.Get("Text"),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 12,
					Font = isSelected and Enum.Font.GothamBold or Theme.Typography.Subtitle.Font,
					AutoButtonColor = false,
					Parent = scrollContainer,
				})
				Elements.Round(itemBtn, 4)

				itemBtn.MouseButton1Click:Connect(function()
					if isMulti then
						currentValue[itemVal] = not currentValue[itemVal]
						dropdownObj:SetValue(currentValue)
						refreshItems(searchBox.Text)
					else
						dropdownObj:SetValue(itemVal)
						isOpen = false
						arrow.Text = "⌄"
						Popover.Close()
					end
				end)
			end
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		refreshItems(searchBox.Text)
	end)

	local themeConn = Theme.Changed:Connect(function(palette)
		valLabel.TextColor3 = palette.Text
		if isOpen then
			refreshItems(searchBox.Text)
		end
	end)

	box.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		arrow.Text = isOpen and "⌃" or "⌄"
		if isOpen then
			local targetW = math.max(box.AbsoluteSize.X, 180)
			local count = math.min(#dropdownObj.Values, 7)
			local targetH = math.clamp(count * 28 + (#dropdownObj.Values > 8 and 38 or 12), 60, 240)
			listFrame.Size = UDim2.fromOffset(targetW, targetH)
			refreshItems("")
			Popover.Open(listFrame, box, function()
				isOpen = false
				arrow.Text = "⌄"
			end)
		else
			Popover.Close()
		end
	end)

	container.Destroying:Connect(function()
		themeConn:Disconnect()
		listFrame:Destroy()
	end)

	if registry then
		registry[id] = dropdownObj
	end

	return dropdownObj
end

return Dropdown
