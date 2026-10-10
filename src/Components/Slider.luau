local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)

local Slider = {}

local function round(val, decimals)
	local factor = 10 ^ (decimals or 0)
	return math.round(val * factor) / factor
end

function Slider.New(parent, id, options, registry, isRow)
	options = options or {}
	local minVal = options.Min or 0
	local maxVal = options.Max or 100
	if maxVal <= minVal then
		maxVal = minVal + 1
	end

	local roundingDecimals = options.Rounding or 0
	local suffix = options.Suffix or ""
	local currentVal = math.clamp(round(options.Default or minVal, roundingDecimals), minVal, maxVal)
	local callback = options.Callback or function() end

	local frame = nil
	local trackHolder = nil
	local valLabel = nil
	local valInput = nil

	if isRow then
		frame = Elements.Create("Frame", {
			Name = id .. "_SliderHolder",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = parent,
		})

		local layout = Elements.Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
			Parent = frame,
		})

		trackHolder = Elements.Create("Frame", {
			Name = "TrackHolder",
			Size = UDim2.new(1, -64, 0, 20),
			BackgroundTransparency = 1,
			Parent = frame,
		})

		valLabel = Elements.Create("TextButton", {
			Name = "ValueLabel",
			Size = UDim2.new(0, 54, 0, 24),
			BackgroundTransparency = 1,
			Text = tostring(currentVal) .. suffix,
			TextColor3 = Theme.Get("SecondaryText"),
			TextSize = Theme.Typography.Subtitle.Size,
			Font = Theme.Typography.Subtitle.Font,
			TextXAlignment = Enum.TextXAlignment.Right,
			AutoButtonColor = false,
			Parent = frame,
		})
		Theme.Register(valLabel, "TextColor3", "SecondaryText")
	else
		frame = Elements.Create("Frame", {
			Name = id .. "_Slider",
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundTransparency = 1,
			Parent = parent,
		})

		local header = Elements.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Parent = frame,
		})

		local titleLabel = Elements.Create("TextLabel", {
			Size = UDim2.new(1, -60, 1, 0),
			BackgroundTransparency = 1,
			Text = options.Text or id,
			TextColor3 = Theme.Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = Theme.Typography.RowTitle.Size,
			Font = Theme.Typography.RowTitle.Font,
			Parent = header,
		})
		Theme.Register(titleLabel, "TextColor3", "Text")

		valLabel = Elements.Create("TextButton", {
			Size = UDim2.new(0, 60, 1, 0),
			Position = UDim2.new(1, -60, 0, 0),
			BackgroundTransparency = 1,
			Text = tostring(currentVal) .. suffix,
			TextColor3 = Theme.Get("SecondaryText"),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextSize = Theme.Typography.Subtitle.Size,
			Font = Theme.Typography.Subtitle.Font,
			AutoButtonColor = false,
			Parent = header,
		})
		Theme.Register(valLabel, "TextColor3", "SecondaryText")

		trackHolder = Elements.Create("Frame", {
			Name = "TrackHolder",
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 22),
			BackgroundTransparency = 1,
			Parent = frame,
		})
	end

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	-- Inline TextBox for direct typing (revealed on double-click)
	valInput = Elements.Create("TextBox", {
		Name = "ValueInput",
		Size = valLabel.Size,
		Position = valLabel.Position,
		BackgroundColor3 = Theme.Get("ControlFill"),
		BackgroundTransparency = 0,
		Text = tostring(currentVal),
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.Subtitle.Size,
		Font = Theme.Typography.Subtitle.Font,
		ClearTextOnFocus = false,
		Visible = false,
		Parent = valLabel.Parent,
	})
	Elements.Round(valInput, 4)
	Theme.Register(valInput, "BackgroundColor3", "ControlFill")
	Theme.Register(valInput, "TextColor3", "Text")

	-- 4px Height Track
	local track = Elements.Create("TextButton", {
		Name = "Track",
		Size = UDim2.new(1, 0, 0, 4),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Theme.Get("ControlFill"),
		Text = "",
		AutoButtonColor = false,
		Parent = trackHolder,
	})
	Elements.Round(track, 2)
	Theme.Register(track, "BackgroundColor3", "ControlFill")

	local percent = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)

	local fill = Elements.Create("Frame", {
		Name = "Fill",
		Size = UDim2.new(percent, 0, 1, 0),
		BackgroundColor3 = Theme.Get("Accent"),
		Parent = track,
	})
	Elements.Round(fill, 2)
	Theme.Register(fill, "BackgroundColor3", "Accent")

	-- 16px White Knob centered on thumb
	local knob = Elements.Create("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(percent, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = track,
	})
	Elements.Round(knob, 8)

	local knobShadow = Elements.Create("ImageLabel", {
		Name = "KnobShadow",
		Size = UDim2.new(1, 6, 1, 6),
		Position = UDim2.fromOffset(-3, -2),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.6,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = knob.ZIndex - 1,
		Parent = knob,
	})

	local isDragging = false
	local parentScroll = nil
	local originalScrollState = true

	local sliderObj = {
		Value = currentVal,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newVal)
			local clamped = math.clamp(round(newVal, roundingDecimals), minVal, maxVal)
			local p = math.clamp((clamped - minVal) / (maxVal - minVal), 0, 1)

			fill.Size = UDim2.new(p, 0, 1, 0)
			knob.Position = UDim2.new(p, 0, 0.5, 0)
			valLabel.Text = tostring(clamped) .. suffix

			if clamped == self.Value then
				return
			end

			self.Value = clamped
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

	-- Double-click to type directly
	local lastClick = 0
	valLabel.MouseButton1Click:Connect(function()
		local now = os.clock()
		if now - lastClick < 0.35 then
			valLabel.Visible = false
			valInput.Visible = true
			valInput.Text = tostring(sliderObj.Value)
			valInput:CaptureFocus()
		end
		lastClick = now
	end)

	valInput.FocusLost:Connect(function(enterPressed)
		valInput.Visible = false
		valLabel.Visible = true
		local num = tonumber(valInput.Text)
		if num then
			sliderObj:SetValue(num)
		end
	end)

	local function updateFromInput(inputPos)
		local absPos = track.AbsolutePosition
		local absSize = track.AbsoluteSize
		if absSize.X <= 0 then return end
		local relativeX = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
		local val = minVal + (maxVal - minVal) * relativeX
		sliderObj:SetValue(val)
	end

	local c1 = trackHolder.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			parentScroll = trackHolder:FindFirstAncestorOfClass("ScrollingFrame")
			if parentScroll then
				originalScrollState = parentScroll.ScrollingEnabled
				parentScroll.ScrollingEnabled = false
			end
			updateFromInput(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)

	local c2 = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if isDragging then
				isDragging = false
				if parentScroll then
					parentScroll.ScrollingEnabled = originalScrollState
					parentScroll = nil
				end
			end
		end
	end)

	local c3 = UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInput(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)

	frame.Destroying:Connect(function()
		c1:Disconnect()
		c2:Disconnect()
		c3:Disconnect()
	end)

	if registry then
		registry[id] = sliderObj
	end

	return sliderObj
end

return Slider
