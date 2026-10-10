--!strict
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)

local Dropdown = {}

export type DropdownOptions = {
	Text: string,
	Values: { string },
	Default: any?,
	Multi: boolean?,
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
		ClipsDescendants = false,
		ZIndex = 5,
		Parent = parent,
	}) :: Frame

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Text or id,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		ZIndex = 5,
		Parent = frame,
	}) :: TextLabel
	Theme.Register(label, "TextColor3", "Text")

	local box = Elements.Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5,
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
		ZIndex = 5,
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
		ZIndex = 5,
		Parent = box,
	}) :: TextLabel
	Theme.Register(arrow, "TextColor3", "SubText")

	local listFrame = Elements.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 1, 4),
		BackgroundColor3 = Theme.Get("Secondary"),
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Get("Accent"),
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 20,
		Parent = box,
	}) :: ScrollingFrame
	Elements.Round(listFrame, 6)
	local listStroke = Elements.Stroke(listFrame, Theme.Get("Border"), 1, 0)
	Theme.Register(listFrame, "BackgroundColor3", "Secondary")
	Theme.Register(listStroke, "Color", "Border")

	local layout = Elements.Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = listFrame,
	}) :: UIListLayout
	Elements.Padding(listFrame, 4)

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
		SetValues = function(self: any, newValues: { string })
			self.Values = newValues
			-- rebuild items
		end,
	}

	local function refreshItems()
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for _, itemVal in ipairs(dropdownObj.Values) do
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
				ZIndex = 21,
				Parent = listFrame,
			}) :: TextButton
			Elements.Round(itemBtn, 4)

			itemBtn.MouseButton1Click:Connect(function()
				if isMulti then
					currentValue[itemVal] = not currentValue[itemVal]
					dropdownObj:SetValue(currentValue)
					refreshItems()
				else
					dropdownObj:SetValue(itemVal)
					isOpen = false
					listFrame.Visible = false
					arrow.Text = "v"
					frame.ZIndex = 5
				end
			end)
		end

		local totalHeight = math.min(#dropdownObj.Values * 26 + 8, 140)
		listFrame.Size = UDim2.new(1, 0, 0, totalHeight)
		listFrame.CanvasSize = UDim2.new(0, 0, 0, #dropdownObj.Values * 26 + 8)
	end

	box.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		arrow.Text = isOpen and "^" or "v"
		if isOpen then
			frame.ZIndex = 50
			box.ZIndex = 50
			refreshItems()
			listFrame.Visible = true
		else
			frame.ZIndex = 5
			box.ZIndex = 5
			listFrame.Visible = false
		end
	end)

	registry[id] = dropdownObj
	return dropdownObj
end

return Dropdown
