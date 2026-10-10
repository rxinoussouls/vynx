local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)
local Colorpicker = require(script.Parent.Colorpicker)
local Keybind = require(script.Parent.Keybind)

local Toggle = {}

function Toggle.New(parent, id, options, library, isRow)
	options = options or {}
	local state = options.Default or false
	local callback = options.Callback or function() end

	local container = nil
	if isRow then
		container = Elements.Create("Frame", {
			Name = id .. "_ToggleHolder",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Parent = parent,
		})
	else
		container = Elements.Create("TextButton", {
			Name = id .. "_Toggle",
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Parent = parent,
		})

		local label = Elements.Create("TextLabel", {
			Size = UDim2.new(1, -120, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = options.Text or id,
			TextColor3 = Theme.Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextSize = Theme.Typography.RowTitle.Size,
			Font = Theme.Typography.RowTitle.Font,
			Parent = container,
		})
		Theme.Register(label, "TextColor3", "Text")
	end

	if options.Tooltip then
		Tooltip.Attach(container, options.Tooltip)
	end

	local subHolder = Elements.Create("Frame", {
		Name = "SubHolder",
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = isRow and Vector2.new(1, 0.5) or Vector2.new(1, 0.5),
		Position = isRow and UDim2.new(1, 0, 0.5, 0) or UDim2.new(1, -2, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = container,
	})

	local subLayout = Elements.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = subHolder,
	})

	-- macOS Switch Pill (40x24)
	local switchBtn = Elements.Create("TextButton", {
		Name = "SwitchPill",
		Size = UDim2.fromOffset(40, 24),
		BackgroundColor3 = state and Theme.Get("Accent") or Theme.Get("ControlFill"),
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 10,
		Parent = subHolder,
	})
	Elements.Round(switchBtn, 12)
	local switchStroke = Elements.Stroke(switchBtn, Theme.Get("Hairline"), 1, 0)
	Theme.Register(switchStroke, "Color", "Hairline")

	-- 20px Knob with subtle shadow
	local knob = Elements.Create("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = switchBtn,
	})
	Elements.Round(knob, 10)

	local knobShadow = Elements.Create("ImageLabel", {
		Name = "KnobShadow",
		Size = UDim2.new(1, 6, 1, 6),
		Position = UDim2.fromOffset(-3, -2),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.65,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = knob.ZIndex - 1,
		Parent = knob,
	})

	local isPressed = false
	local function updateVisuals(value, animate)
		local duration = animate and Motion.Duration.Base or 0
		local targetColor = value and Theme.Get("Accent") or Theme.Get("ControlFill")
		local targetPos = value and UDim2.new(1, isPressed and -26 or -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		local targetSize = isPressed and UDim2.fromOffset(24, 20) or UDim2.fromOffset(20, 20)

		if animate then
			Elements.Tween(switchBtn, TweenInfo.new(duration, Motion.Easing.QuintOut), { BackgroundColor3 = targetColor })
			Elements.Tween(knob, TweenInfo.new(duration, Motion.Easing.QuintOut), {
				Position = targetPos,
				Size = targetSize,
			})
		else
			switchBtn.BackgroundColor3 = targetColor
			knob.Position = targetPos
			knob.Size = targetSize
		end
	end

	local themeConn = Theme.Changed:Connect(function(palette)
		if state then
			switchBtn.BackgroundColor3 = palette.Accent
		else
			switchBtn.BackgroundColor3 = palette.ControlFill
		end
	end)

	local toggleObj = {
		Value = state,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newValue)
			if self.Value == newValue then return end
			self.Value = newValue
			state = newValue
			updateVisuals(newValue, true)
			task.spawn(self.Callback, newValue)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newValue)
			end
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
		end,
		AddColorpicker = function(self, subId, subOptions)
			local cp = Colorpicker.New(subHolder, subId, subOptions, library.Options, true)
			cp.Frame.LayoutOrder = 5
			return cp
		end,
		AddKeybind = function(self, subId, subOptions)
			local kb = Keybind.New(subHolder, subId, subOptions, library.Options, true)
			kb.Frame.LayoutOrder = 4
			return kb
		end,
	}

	-- Knob stretch micro-interaction
	switchBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isPressed = true
			Elements.Tween(knob, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), {
				Size = UDim2.fromOffset(24, 20),
				Position = state and UDim2.new(1, -26, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			})
		end
	end)

	switchBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isPressed = false
			Elements.Tween(knob, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuintOut), {
				Size = UDim2.fromOffset(20, 20),
				Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			})
		end
	end)

	switchBtn.MouseButton1Click:Connect(function()
		toggleObj:SetValue(not toggleObj.Value)
	end)

	if not isRow then
		container.MouseButton1Click:Connect(function()
			toggleObj:SetValue(not toggleObj.Value)
		end)
	end

	container.Destroying:Connect(function()
		themeConn:Disconnect()
	end)

	if library and library.Toggles then
		library.Toggles[id] = toggleObj
	end

	return toggleObj
end

return Toggle
