--!strict
local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)

local Keybind = {}

export type KeybindOptions = {
	Text: string,
	Default: Enum.KeyCode?,
	Mode: ("Toggle" | "Hold" | "Always")?,
	Callback: ((boolean) -> ())?,
}

function Keybind.New(parent: GuiObject, id: string, options: KeybindOptions, registry: { [string]: any })
	local currentKey: Enum.KeyCode? = options.Default or Enum.KeyCode.Unknown
	local mode = options.Mode or "Toggle"
	local callback = options.Callback or function() end
	local isBinding = false
	local isHolding = false

	local frame = Elements.Create("Frame", {
		Name = id .. "_Keybind",
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = parent,
	}) :: Frame

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -90, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Text or id,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		Parent = frame,
	}) :: TextLabel
	Theme.Register(label, "TextColor3", "Text")

	local keyBtn = Elements.Create("TextButton", {
		Size = UDim2.new(0, 80, 0, 20),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -2, 0.5, 0),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = currentKey and (currentKey :: Enum.KeyCode).Name or "None",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		Parent = frame,
	}) :: TextButton
	Elements.Round(keyBtn, 4)
	local keyStroke = Elements.Stroke(keyBtn, Theme.Get("Border"), 1, 0)
	Theme.Register(keyBtn, "BackgroundColor3", "Surface")
	Theme.Register(keyStroke, "Color", "Border")

	if not options.Text or options.Text == "" then
		label.Visible = false
	end

	local keybindObj = {
		Frame = frame,
		Value = currentKey,
		Mode = mode,
		Callback = callback,
		SetValue = function(self: any, newKey: Enum.KeyCode)
			self.Value = newKey
			currentKey = newKey
			keyBtn.Text = newKey and newKey.Name or "None"
		end,
	}

	keyBtn.MouseButton1Click:Connect(function()
		isBinding = true
		keyBtn.Text = "..."
		keyStroke.Color = Theme.Get("Accent")
	end)

	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if isBinding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				isBinding = false
				keyStroke.Color = Theme.Get("Border")
				if input.KeyCode == Enum.KeyCode.Escape then
					keybindObj:SetValue(Enum.KeyCode.Unknown)
				else
					keybindObj:SetValue(input.KeyCode)
				end
			end
		elseif not gameProcessed and currentKey and input.KeyCode == currentKey then
			if mode == "Toggle" then
				task.spawn(keybindObj.Callback, true)
			elseif mode == "Hold" then
				isHolding = true
				task.spawn(keybindObj.Callback, true)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input: InputObject)
		if not isBinding and currentKey and input.KeyCode == currentKey and mode == "Hold" and isHolding then
			isHolding = false
			task.spawn(keybindObj.Callback, false)
		end
	end)

	registry[id] = keybindObj
	return keybindObj
end

return Keybind
