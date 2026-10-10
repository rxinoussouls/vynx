local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)
local Colorpicker = require(script.Parent.Colorpicker)
local Keybind = require(script.Parent.Keybind)

local Toggle = {}

function Toggle.New(parent, id, options, library)
	local state = options.Default or false
	local callback = options.Callback or function() end

	local frame = Elements.Create("TextButton", {
		Name = id .. "_Toggle",
		Size = UDim2.new(1, 0, 0, 24),
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
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		Parent = frame,
	})
	Theme.Register(label, "TextColor3", "Text")

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	local subHolder = Elements.Create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -2, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	local subLayout = Elements.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = subHolder,
	})

	local switchBg = Elements.Create("Frame", {
		Name = "Switch",
		Size = UDim2.new(0, 36, 0, 18),
		BackgroundColor3 = state and Theme.Get("Accent") or Theme.Get("Surface"),
		LayoutOrder = 10,
		Parent = subHolder,
	})
	Elements.Round(switchBg, 9)
	local switchStroke = Elements.Stroke(switchBg, Theme.Get("Border"), 1, 0)
	Theme.Register(switchStroke, "Color", "Border")

	local knob = Elements.Create("Frame", {
		Size = UDim2.new(0, 14, 0, 14),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = switchBg,
	})
	Elements.Round(knob, 7)

	local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function updateVisuals(value)
		if value then
			Elements.Tween(switchBg, tweenInfo, { BackgroundColor3 = Theme.Get("Accent") })
			Elements.Tween(knob, tweenInfo, { Position = UDim2.new(1, -16, 0.5, 0) })
		else
			Elements.Tween(switchBg, tweenInfo, { BackgroundColor3 = Theme.Get("Surface") })
			Elements.Tween(knob, tweenInfo, { Position = UDim2.new(0, 2, 0.5, 0) })
		end
	end

	local themeConn = Theme.Changed:Connect(function(palette)
		if state then
			switchBg.BackgroundColor3 = palette.Accent
		else
			switchBg.BackgroundColor3 = palette.Surface
		end
	end)

	local toggleObj = {
		Value = state,
		Callback = callback,
		SetValue = function(self, newValue)
			if self.Value == newValue then return end
			self.Value = newValue
			state = newValue
			updateVisuals(newValue)
			task.spawn(self.Callback, newValue)
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

	frame.MouseButton1Click:Connect(function()
		toggleObj:SetValue(not toggleObj.Value)
	end)

	frame.Destroying:Connect(function()
		themeConn:Disconnect()
	end)

	library.Toggles[id] = toggleObj
	return toggleObj
end

return Toggle
