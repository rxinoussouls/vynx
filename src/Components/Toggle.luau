--!strict
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)

local Toggle = {}

export type ToggleOptions = {
	Text: string,
	Default: boolean?,
	Tooltip: string?,
	Callback: ((boolean) -> ())?,
}

function Toggle.New(parent: GuiObject, id: string, options: ToggleOptions, registry: { [string]: any })
	local state = options.Default or false
	local callback = options.Callback or function() end

	local frame = Elements.Create("TextButton", {
		Name = id .. "_Toggle",
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = parent,
	}) :: TextButton

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = options.Text or id,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		Parent = frame,
	}) :: TextLabel
	Theme.Register(label, "TextColor3", "Text")

	local switchBg = Elements.Create("Frame", {
		Size = UDim2.new(0, 36, 0, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -2, 0.5, 0),
		BackgroundColor3 = state and Theme.Get("Accent") or Theme.Get("Surface"),
		Parent = frame,
	}) :: Frame
	Elements.Round(switchBg, 9)
	local switchStroke = Elements.Stroke(switchBg, Theme.Get("Border"), 1, 0)
	Theme.Register(switchStroke, "Color", "Border")

	local knob = Elements.Create("Frame", {
		Size = UDim2.new(0, 14, 0, 14),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = switchBg,
	}) :: Frame
	Elements.Round(knob, 7)

	local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function updateVisuals(value: boolean)
		if value then
			Elements.Tween(switchBg, tweenInfo, { BackgroundColor3 = Theme.Get("Accent") })
			Elements.Tween(knob, tweenInfo, { Position = UDim2.new(1, -16, 0.5, 0) })
		else
			Elements.Tween(switchBg, tweenInfo, { BackgroundColor3 = Theme.Get("Surface") })
			Elements.Tween(knob, tweenInfo, { Position = UDim2.new(0, 2, 0.5, 0) })
		end
	end

	local toggleObj = {
		Value = state,
		Callback = callback,
		SetValue = function(self: any, newValue: boolean)
			if self.Value == newValue then return end
			self.Value = newValue
			updateVisuals(newValue)
			task.spawn(self.Callback, newValue)
		end,
	}

	frame.MouseButton1Click:Connect(function()
		toggleObj:SetValue(not toggleObj.Value)
	end)

	registry[id] = toggleObj
	return toggleObj
end

return Toggle
