--!strict
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)

local Input = {}

export type InputOptions = {
	Text: string,
	Default: string?,
	Placeholder: string?,
	Numeric: boolean?,
	Finished: boolean?,
	Tooltip: string?,
	Callback: ((string) -> ())?,
}

function Input.New(parent: GuiObject, id: string, options: InputOptions, registry: { [string]: any })
	local currentText = options.Default or ""
	local callback = options.Callback or function() end
	local isFinishedMode = if options.Finished ~= nil then options.Finished else true

	local frame = Elements.Create("Frame", {
		Name = id .. "_Input",
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

	local inputBg = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundColor3 = Theme.Get("Surface"),
		Parent = frame,
	}) :: Frame
	Elements.Round(inputBg, 6)
	local stroke = Elements.Stroke(inputBg, Theme.Get("Border"), 1, 0)
	Theme.Register(inputBg, "BackgroundColor3", "Surface")
	Theme.Register(stroke, "Color", "Border")

	local textBox = Elements.Create("TextBox", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = currentText,
		PlaceholderText = options.Placeholder or "Enter text...",
		PlaceholderColor3 = Theme.Get("SubText"),
		TextColor3 = Theme.Get("Text"),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.Gotham,
		ClearTextOnFocus = false,
		Parent = inputBg,
	}) :: TextBox
	Theme.Register(textBox, "TextColor3", "Text")
	Theme.Register(textBox, "PlaceholderColor3", "SubText")

	local inputObj = {
		Value = currentText,
		Callback = callback,
		SetValue = function(self: any, newText: string)
			if self.Value == newText and textBox.Text == newText then return end
			self.Value = newText
			textBox.Text = newText
			task.spawn(self.Callback, newText)
		end,
	}

	textBox.Focused:Connect(function()
		Elements.Tween(stroke, TweenInfo.new(0.15), { Color = Theme.Get("Accent") })
	end)

	if isFinishedMode then
		-- Only fire when user presses Enter or clicks outside
		textBox.FocusLost:Connect(function(enterPressed: boolean)
			Elements.Tween(stroke, TweenInfo.new(0.15), { Color = Theme.Get("Border") })
			local text = textBox.Text
			if options.Numeric then
				text = string.gsub(text, "[^%d.-]", "")
				textBox.Text = text
			end
			inputObj.Value = text
			task.spawn(inputObj.Callback, text)
		end)
	else
		-- Only fire on live text change
		textBox.FocusLost:Connect(function()
			Elements.Tween(stroke, TweenInfo.new(0.15), { Color = Theme.Get("Border") })
		end)

		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = textBox.Text
			if options.Numeric then
				text = string.gsub(text, "[^%d.-]", "")
			end
			inputObj.Value = text
			task.spawn(inputObj.Callback, text)
		end)
	end

	registry[id] = inputObj
	return inputObj
end

return Input
