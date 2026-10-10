local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)

local Segmented = {}

function Segmented.New(parent, id, options, registry)
	options = options or {}
	local items = options.Values or options.Options or {}
	local selected = options.Default or items[1] or ""
	local callback = options.Callback or function() end

	local totalItems = math.max(#items, 1)

	local container = Elements.Create("Frame", {
		Name = id .. "_Segmented",
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Theme.Get("ControlFill"),
		ClipsDescendants = false,
		Parent = parent,
	})
	Elements.Round(container, 6)
	local stroke = Elements.Stroke(container, Theme.Get("Hairline"), 1, 0)
	Theme.Register(container, "BackgroundColor3", "ControlFill")
	Theme.Register(stroke, "Color", "Hairline")
	Elements.Padding(container, { Top = 2, Bottom = 2, Left = 2, Right = 2 })

	-- Selection Sliding Pill
	local itemWidth = 1 / totalItems
	local activeIndex = 1
	for idx, val in ipairs(items) do
		if val == selected then
			activeIndex = idx
			break
		end
	end

	local indicator = Elements.Create("Frame", {
		Name = "Indicator",
		Size = UDim2.new(itemWidth, 0, 1, 0),
		Position = UDim2.new(itemWidth * (activeIndex - 1), 0, 0, 0),
		BackgroundColor3 = Theme.Get("FormCard"),
		ZIndex = 2,
		Parent = container,
	})
	Elements.Round(indicator, 5)
	local indicatorStroke = Elements.Stroke(indicator, Theme.Get("Hairline"), 1, 0.5)
	Theme.Register(indicator, "BackgroundColor3", "FormCard")
	Theme.Register(indicatorStroke, "Color", "Hairline")

	local buttons = {}
	local segmentedObj = {
		Value = selected,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newVal)
			local foundIndex = nil
			for idx, val in ipairs(items) do
				if val == newVal then
					foundIndex = idx
					break
				end
			end
			if not foundIndex or self.Value == newVal then return end

			self.Value = newVal
			Elements.Tween(indicator, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuintOut), {
				Position = UDim2.new(itemWidth * (foundIndex - 1), 0, 0, 0),
			})

			for idx, btn in ipairs(buttons) do
				btn.TextColor3 = (idx == foundIndex) and Theme.Get("Text") or Theme.Get("SecondaryText")
				btn.Font = (idx == foundIndex) and Enum.Font.GothamBold or Enum.Font.GothamMedium
			end

			task.spawn(self.Callback, newVal)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newVal)
			end
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
		end,
	}

	for idx, itemText in ipairs(items) do
		local btn = Elements.Create("TextButton", {
			Name = "Segment_" .. idx,
			Size = UDim2.new(itemWidth, 0, 1, 0),
			Position = UDim2.new(itemWidth * (idx - 1), 0, 0, 0),
			BackgroundTransparency = 1,
			Text = tostring(itemText),
			TextColor3 = (idx == activeIndex) and Theme.Get("Text") or Theme.Get("SecondaryText"),
			TextSize = Theme.Typography.Subtitle.Size,
			Font = (idx == activeIndex) and Enum.Font.GothamBold or Enum.Font.GothamMedium,
			AutoButtonColor = false,
			ZIndex = 3,
			Parent = container,
		})

		btn.MouseButton1Click:Connect(function()
			segmentedObj:SetValue(itemText)
		end)

		table.insert(buttons, btn)
	end

	if registry then
		registry[id] = segmentedObj
	end

	return segmentedObj
end

return Segmented
