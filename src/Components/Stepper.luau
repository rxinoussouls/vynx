local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)

local Stepper = {}

function Stepper.New(parent, id, options, registry)
	options = options or {}
	local minVal = options.Min or 0
	local maxVal = options.Max or 100
	local step = options.Step or 1
	local currentVal = math.clamp(options.Default or minVal, minVal, maxVal)
	local callback = options.Callback or function() end
	local suffix = options.Suffix or ""

	local container = Elements.Create("Frame", {
		Name = id .. "_StepperHolder",
		Size = UDim2.new(0, 0, 0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local layout = Elements.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = container,
	})

	local valLabel = Elements.Create("TextLabel", {
		Name = "ValueLabel",
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = tostring(currentVal) .. suffix,
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.Subtitle.Size,
		Font = Theme.Typography.Subtitle.Font,
		Parent = container,
	})
	Theme.Register(valLabel, "TextColor3", "Text")

	local capsule = Elements.Create("Frame", {
		Name = "StepperCapsule",
		Size = UDim2.fromOffset(56, 28),
		BackgroundColor3 = Theme.Get("ControlFill"),
		ClipsDescendants = true,
		Parent = container,
	})
	Elements.Round(capsule, 6)
	local stroke = Elements.Stroke(capsule, Theme.Get("Hairline"), 1, 0)
	Theme.Register(capsule, "BackgroundColor3", "ControlFill")
	Theme.Register(stroke, "Color", "Hairline")

	local minusBtn = Elements.Create("TextButton", {
		Name = "Minus",
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "−",
		TextColor3 = Theme.Get("Text"),
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		Parent = capsule,
	})
	Theme.Register(minusBtn, "TextColor3", "Text")

	local divider = Elements.Create("Frame", {
		Name = "Divider",
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundColor3 = Theme.Get("Hairline"),
		BorderSizePixel = 0,
		Parent = capsule,
	})
	Theme.Register(divider, "BackgroundColor3", "Hairline")

	local plusBtn = Elements.Create("TextButton", {
		Name = "Plus",
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "+",
		TextColor3 = Theme.Get("Text"),
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		Parent = capsule,
	})
	Theme.Register(plusBtn, "TextColor3", "Text")

	local stepperObj = {
		Value = currentVal,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newVal)
			local clamped = math.clamp(newVal, minVal, maxVal)
			if clamped == self.Value then return end
			self.Value = clamped
			valLabel.Text = tostring(clamped) .. suffix
			task.spawn(self.Callback, clamped)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, clamped)
			end
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
		end,
	}

	minusBtn.MouseButton1Click:Connect(function()
		stepperObj:SetValue(stepperObj.Value - step)
	end)

	plusBtn.MouseButton1Click:Connect(function()
		stepperObj:SetValue(stepperObj.Value + step)
	end)

	if registry then
		registry[id] = stepperObj
	end

	return stepperObj
end

return Stepper
