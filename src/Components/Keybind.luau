local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)

local Keybind = {}

function Keybind.New(parent, id, options, registry, isEmbedded)
	local currentKey = options.Default or Enum.KeyCode.Unknown
	local mode = options.Mode or "Toggle"
	local callback = options.Callback or function() end
	local isBinding = false
	local isHolding = false
	local isToggled = false

	local frame = Elements.Create("Frame", {
		Name = id .. "_Keybind",
		Size = isEmbedded and UDim2.new(0, 46, 0, 18) or UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = parent,
	})

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	if not isEmbedded and (options.Text and options.Text ~= "") then
		local label = Elements.Create("TextLabel", {
			Size = UDim2.new(1, -70, 1, 0),
			BackgroundTransparency = 1,
			Text = options.Text or id,
			TextColor3 = Theme.Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			Parent = frame,
		})
		Theme.Register(label, "TextColor3", "Text")
	end

	local keyBtn = Elements.Create("TextButton", {
		Size = isEmbedded and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 60, 0, 20),
		AnchorPoint = isEmbedded and Vector2.zero or Vector2.new(1, 0.5),
		Position = isEmbedded and UDim2.new(0, 0, 0, 0) or UDim2.new(1, -2, 0.5, 0),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = currentKey and currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		Parent = frame,
	})
	Elements.Round(keyBtn, 4)
	local keyStroke = Elements.Stroke(keyBtn, Theme.Get("Border"), 1, 0)
	Theme.Register(keyBtn, "BackgroundColor3", "Surface")
	Theme.Register(keyStroke, "Color", "Border")

	local keybindObj = {
		Frame = frame,
		Value = currentKey,
		Mode = mode,
		Toggled = false,
		Callback = callback,
		SetValue = function(self, newKey)
			self.Value = newKey
			currentKey = newKey
			keyBtn.Text = newKey and newKey ~= Enum.KeyCode.Unknown and newKey.Name or "None"
		end,
		SetMode = function(self, newMode)
			self.Mode = newMode
			mode = newMode
		end,
	}

	keyBtn.MouseButton1Click:Connect(function()
		isBinding = true
		keyBtn.Text = "..."
		keyStroke.Color = Theme.Get("Accent")
	end)

	keyBtn.MouseButton2Click:Connect(function()
		if mode == "Toggle" then
			keybindObj:SetMode("Hold")
		elseif mode == "Hold" then
			keybindObj:SetMode("Always")
			keybindObj.Toggled = true
			task.spawn(keybindObj.Callback, true)
		else
			keybindObj:SetMode("Toggle")
		end
	end)

	local c1 = UserInputService.InputBegan:Connect(function(input, gameProcessed)
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
		elseif not gameProcessed and currentKey and currentKey ~= Enum.KeyCode.Unknown and input.KeyCode == currentKey then
			if mode == "Toggle" then
				isToggled = not isToggled
				keybindObj.Toggled = isToggled
				task.spawn(keybindObj.Callback, isToggled)
			elseif mode == "Hold" then
				isHolding = true
				keybindObj.Toggled = true
				task.spawn(keybindObj.Callback, true)
			elseif mode == "Always" then
				keybindObj.Toggled = true
				task.spawn(keybindObj.Callback, true)
			end
		end
	end)

	local c2 = UserInputService.InputEnded:Connect(function(input)
		if not isBinding and currentKey and currentKey ~= Enum.KeyCode.Unknown and input.KeyCode == currentKey and mode == "Hold" and isHolding then
			isHolding = false
			keybindObj.Toggled = false
			task.spawn(keybindObj.Callback, false)
		end
	end)

	frame.Destroying:Connect(function()
		c1:Disconnect()
		c2:Disconnect()
	end)

	registry[id] = keybindObj
	return keybindObj
end

return Keybind
