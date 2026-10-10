local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)

local Input = {}

function Input.New(parent, id, options, registry, isRow)
	options = options or {}
	local currentText = options.Default or ""
	local callback = options.Callback or function() end
	local isFinishedMode = true
	if options.Finished ~= nil then
		isFinishedMode = options.Finished
	end

	local container = nil
	local inputBg = nil

	if isRow then
		container = Elements.Create("Frame", {
			Name = id .. "_InputHolder",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = parent,
		})

		inputBg = Elements.Create("Frame", {
			Name = "InputBg",
			Size = UDim2.new(1, 0, 0, 28),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Theme.Get("ControlFill"),
			Parent = container,
		})
	else
		container = Elements.Create("Frame", {
			Name = id .. "_Input",
			Size = UDim2.new(1, 0, 0, 48),
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

		inputBg = Elements.Create("Frame", {
			Name = "InputBg",
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 0, 20),
			BackgroundColor3 = Theme.Get("ControlFill"),
			Parent = container,
		})
	end

	Elements.Round(inputBg, 6)
	local stroke = Elements.Stroke(inputBg, Theme.Get("Hairline"), 1, 0)
	Theme.Register(inputBg, "BackgroundColor3", "ControlFill")
	Theme.Register(stroke, "Color", "Hairline")

	if options.Tooltip then
		Tooltip.Attach(container, options.Tooltip)
	end

	local textBox = Elements.Create("TextBox", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = currentText,
		PlaceholderText = options.Placeholder or "Enter text...",
		PlaceholderColor3 = Theme.Get("TertiaryText"),
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.Subtitle.Size,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Theme.Typography.Subtitle.Font,
		ClearTextOnFocus = false,
		Parent = inputBg,
	})
	Theme.Register(textBox, "TextColor3", "Text")
	Theme.Register(textBox, "PlaceholderColor3", "TertiaryText")

	local lastFiredText = currentText

	local inputObj = {
		Value = currentText,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newText)
			newText = tostring(newText or "")
			if self.Value == newText and textBox.Text == newText then return end
			self.Value = newText
			textBox.Text = newText
			lastFiredText = newText
			task.spawn(self.Callback, newText)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newText)
			end
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
		end,
	}

	textBox.Focused:Connect(function()
		Elements.Tween(stroke, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), { Color = Theme.Get("Accent") })
	end)

	local function processText()
		local text = textBox.Text
		if options.Numeric then
			text = string.gsub(text, "[^%d.-]", "")
			textBox.Text = text
		end
		if text ~= lastFiredText then
			lastFiredText = text
			inputObj.Value = text
			task.spawn(inputObj.Callback, text)
			for _, fn in ipairs(inputObj.ChangedCallbacks) do
				task.spawn(fn, text)
			end
		end
	end

	if isFinishedMode then
		textBox.FocusLost:Connect(function()
			Elements.Tween(stroke, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), { Color = Theme.Get("Hairline") })
			processText()
		end)
	else
		textBox.FocusLost:Connect(function()
			Elements.Tween(stroke, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), { Color = Theme.Get("Hairline") })
		end)

		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			processText()
		end)
	end

	if registry then
		registry[id] = inputObj
	end

	return inputObj
end

return Input
