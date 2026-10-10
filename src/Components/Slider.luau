--!strict
local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)

local Slider = {}

export type SliderOptions = {
	Text: string,
	Default: number?,
	Min: number,
	Max: number,
	Rounding: number?,
	Suffix: string?,
	Tooltip: string?,
	Callback: ((number) -> ())?,
}

local function round(val: number, decimals: number?): number
	local factor = 10 ^ (decimals or 0)
	return math.round(val * factor) / factor
end

function Slider.New(parent: GuiObject, id: string, options: SliderOptions, registry: { [string]: any })
	local minVal = options.Min or 0
	local maxVal = options.Max or 100
	local roundingDecimals = options.Rounding or 0
	local suffix = options.Suffix or ""
	local currentVal = math.clamp(round(options.Default or minVal, roundingDecimals), minVal, maxVal)
	local callback = options.Callback or function() end

	local frame = Elements.Create("Frame", {
		Name = id .. "_Slider",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		Parent = parent,
	}) :: Frame

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	local header = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Text or id,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		Parent = header,
	}) :: TextLabel
	Theme.Register(label, "TextColor3", "Text")

	local valLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(0, 60, 1, 0),
		Position = UDim2.new(1, -60, 0, 0),
		BackgroundTransparency = 1,
		Text = tostring(currentVal) .. suffix,
		TextColor3 = Theme.Get("SubText"),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		Parent = header,
	}) :: TextLabel
	Theme.Register(valLabel, "TextColor3", "SubText")

	local track = Elements.Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 0, 24),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	}) :: TextButton
	Elements.Round(track, 5)
	local trackStroke = Elements.Stroke(track, Theme.Get("Border"), 1, 0)
	Theme.Register(track, "BackgroundColor3", "Surface")
	Theme.Register(trackStroke, "Color", "Border")

	local percent = (currentVal - minVal) / (maxVal - minVal)

	local fill = Elements.Create("Frame", {
		Size = UDim2.new(percent, 0, 1, 0),
		BackgroundColor3 = Theme.Get("Accent"),
		Parent = track,
	}) :: Frame
	Elements.Round(fill, 5)
	Theme.Register(fill, "BackgroundColor3", "Accent")

	local sliderObj = {
		Value = currentVal,
		Callback = callback,
		SetValue = function(self: any, newVal: number)
			local clamped = math.clamp(round(newVal, roundingDecimals), minVal, maxVal)
			-- Prevent unneeded tweens and duplicate callbacks when value hasn't changed!
			if clamped == self.Value and fill.Size.X.Scale == (clamped - minVal) / (maxVal - minVal) then
				return
			end
			self.Value = clamped
			valLabel.Text = tostring(clamped) .. suffix
			local p = (clamped - minVal) / (maxVal - minVal)
			Elements.Tween(fill, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(p, 0, 1, 0),
			})
			task.spawn(self.Callback, clamped)
		end,
	}

	local isDragging = false
	local parentScroll: ScrollingFrame? = nil
	local originalScrollState = true

	local function updateFromInput(inputPos: Vector2)
		local absPos = track.AbsolutePosition
		local absSize = track.AbsoluteSize
		local relativeX = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
		local val = minVal + (maxVal - minVal) * relativeX
		sliderObj:SetValue(val)
	end

	local c1 = track.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			-- Disable parent scrolling on mobile/touch while scrubbing
			parentScroll = track:FindFirstAncestorOfClass("ScrollingFrame")
			if parentScroll then
				originalScrollState = parentScroll.ScrollingEnabled
				parentScroll.ScrollingEnabled = false
			end
			updateFromInput(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)

	local c2 = UserInputService.InputEnded:Connect(function(input: InputObject)
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

	local c3 = UserInputService.InputChanged:Connect(function(input: InputObject)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInput(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)

	frame.Destroying:Connect(function()
		c1:Disconnect()
		c2:Disconnect()
		c3:Disconnect()
	end)

	registry[id] = sliderObj
	return sliderObj
end

return Slider
