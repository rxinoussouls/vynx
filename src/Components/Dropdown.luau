--!strict
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)
local Popover = require(script.Parent.Popover)

local Dropdown = {}

export type DropdownOptions = {
	Text: string,
	Values: { string },
	Default: any?,
	Multi: boolean?,
	Tooltip: string?,
	Callback: ((any) -> ())?,
}

function Dropdown.New(parent: GuiObject, id: string, options: DropdownOptions, registry: { [string]: any })
	local values = options.Values or {}
	local isMulti = options.Multi or false
	local callback = options.Callback or function() end
	local isOpen = false

	local currentValue: any
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

	local frame = Elements.Create("Frame", {
		Name = id .. "_Dropdown",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		Parent = parent,
	}) :: Frame

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Text or id,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		Parent = frame,
	}) :: TextLabel
	Theme.Register(label, "TextColor3", "Text")

	local box = Elements.Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	}) :: TextButton
	Elements.Round(box, 6)
	local boxStroke = Elements.Stroke(box, Theme.Get("Border"), 1, 0)
	Theme.Register(box, "BackgroundColor3", "Surface")
	Theme.Register(boxStroke, "Color", "Border")

	local valLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		Parent = box,
	}) :: TextLabel
	Theme.Register(valLabel, "TextColor3", "Text")

	local arrow = Elements.Create("TextLabel", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -22, 0, 0),
		BackgroundTransparency = 1,
		Text = "v",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		Parent = box,
	}) :: TextLabel
	Theme.Register(arrow, "TextColor3", "SubText")

	-- Popover List Frame (rendered in Popover layer to prevent clipping!)
	local listFrame = Elements.Create("Frame", {
		Name = id .. "_PopoverList",
		Size = UDim2.new(0, 240, 0, 160),
		BackgroundColor3 = Theme.Get("Secondary"),
		Visible = false,
	}) :: Frame
	Elements.Round(listFrame, 6)
	local listStroke = Elements.Stroke(listFrame, Theme.Get("Border"), 1, 0)
	Theme.Register(listFrame, "BackgroundColor3", "Secondary")
	Theme.Register(listStroke, "Color", "Border")
	Elements.Padding(listFrame, 6)

	local listLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = listFrame,
	})

	-- Search Input Box inside popover when values > 5
	local searchBox = Elements.Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Theme.Get("Surface"),
		PlaceholderText = "Search...",
		PlaceholderColor3 = Theme.Get("SubText"),
		TextColor3 = Theme.Get("Text"),
		Text = "",
		TextSize = 12,
		Font = Enum.Font.Gotham,
		Visible = #values > 5,
		LayoutOrder = 1,
		Parent = listFrame,
	}) :: TextBox
	Elements.Round(searchBox, 4)
	Theme.Register(searchBox, "BackgroundColor3", "Surface")
	Theme.Register(searchBox, "TextColor3", "Text")

	local scrollContainer = Elements.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, #values > 5 and -28 or 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Get("Accent"),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = listFrame,
	}) :: ScrollingFrame

	local itemsLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = scrollContainer,
	})

	local function getDisplayText(): string
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
		SetValue = function(self: any, newVal: any)
			self.Value = newVal
			currentValue = newVal
			valLabel.Text = getDisplayText()
			task.spawn(self.Callback, newVal)
		end,
	}

	local function refreshItems(filter: string?)
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
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundColor3 = isSelected and Theme.Get("Surface") or Theme.Get("Secondary"),
					BackgroundTransparency = isSelected and 0 or 1,
					Text = "  " .. itemVal,
					TextColor3 = isSelected and Theme.Get("Accent") or Theme.Get("Text"),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 12,
					Font = Enum.Font.GothamMedium,
					AutoButtonColor = false,
					Parent = scrollContainer,
				}) :: TextButton
				Elements.Round(itemBtn, 4)

				itemBtn.MouseButton1Click:Connect(function()
					if isMulti then
						currentValue[itemVal] = not currentValue[itemVal]
						dropdownObj:SetValue(currentValue)
						refreshItems(searchBox.Text)
					else
						dropdownObj:SetValue(itemVal)
						isOpen = false
						arrow.Text = "v"
						Popover.Close()
					end
				end)
			end
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		refreshItems(searchBox.Text)
	end)

	-- Theme change live update for selected item colors
	local themeConn = Theme.Changed:Connect(function(palette)
		valLabel.TextColor3 = palette.Text
		if isOpen then
			refreshItems(searchBox.Text)
		end
	end)

	box.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		arrow.Text = isOpen and "^" or "v"
		if isOpen then
			listFrame.Size = UDim2.new(0, math.max(box.AbsoluteSize.X, 180), 0, math.min(#dropdownObj.Values * 26 + 40, 160))
			refreshItems("")
			Popover.Open(listFrame, box, function()
				isOpen = false
				arrow.Text = "v"
			end)
		else
			Popover.Close()
		end
	end)

	frame.Destroying:Connect(function()
		themeConn:Disconnect()
		listFrame:Destroy()
	end)

	registry[id] = dropdownObj
	return dropdownObj
end

return Dropdown
