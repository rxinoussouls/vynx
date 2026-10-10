local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)

local Keybind = {}

local function formatKeyName(keyOrInput)
	if not keyOrInput or keyOrInput == Enum.KeyCode.Unknown then
		return "None"
	end
	if typeof(keyOrInput) == "EnumItem" then
		return keyOrInput.Name
	end
	return tostring(keyOrInput)
end

function Keybind.New(parent, id, options, registry, isEmbedded)
	options = options or {}
	local currentKey = options.Default or Enum.KeyCode.Unknown
	local mode = options.Mode or "Toggle"
	local callback = options.Callback or function() end
	local isBinding = false
	local isHolding = false
	local isToggled = false

	local frame = Elements.Create("Frame", {
		Name = id .. "_Keybind",
		Size = isEmbedded and UDim2.new(0, 52, 0, 22) or UDim2.new(0, 0, 0, 26),
		AutomaticSize = isEmbedded and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	local keyBtn = Elements.Create("TextButton", {
		Name = "KeyButton",
		Size = isEmbedded and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 0, 24),
		AutomaticSize = isEmbedded and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Get("ControlFill"),
		Text = formatKeyName(currentKey),
		TextColor3 = Theme.Get("Text"),
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		Parent = frame,
	})
	Elements.Round(keyBtn, 6)
	local keyStroke = Elements.Stroke(keyBtn, Theme.Get("Hairline"), 1, 0)
	Elements.Padding(keyBtn, { Top = 0, Bottom = 0, Left = 8, Right = 8 })
	Theme.Register(keyBtn, "BackgroundColor3", "ControlFill")
	Theme.Register(keyBtn, "TextColor3", "Text")
	Theme.Register(keyStroke, "Color", "Hairline")

	local keybindObj = {
		Frame = frame,
		Value = currentKey,
		Mode = mode,
		Toggled = false,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newKey)
			self.Value = newKey
			currentKey = newKey
			keyBtn.Text = formatKeyName(newKey)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newKey)
			end
		end,
		SetMode = function(self, newMode)
			self.Mode = newMode
			mode = newMode
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
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
			local key = nil
			if input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				key = Enum.UserInputType.MouseButton1
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				key = Enum.UserInputType.MouseButton2
			elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
				key = Enum.UserInputType.MouseButton3
			end

			if key then
				isBinding = false
				keyStroke.Color = Theme.Get("Hairline")
				if key == Enum.KeyCode.Escape then
					keybindObj:SetValue(Enum.KeyCode.Unknown)
				else
					keybindObj:SetValue(key)
				end
			end
		elseif not gameProcessed and currentKey and currentKey ~= Enum.KeyCode.Unknown then
			local matches = (input.KeyCode == currentKey) or (input.UserInputType == currentKey)
			if matches then
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
		end
	end)

	local c2 = UserInputService.InputEnded:Connect(function(input)
		if not isBinding and currentKey and currentKey ~= Enum.KeyCode.Unknown then
			local matches = (input.KeyCode == currentKey) or (input.UserInputType == currentKey)
			if matches and mode == "Hold" and isHolding then
				isHolding = false
				keybindObj.Toggled = false
				task.spawn(keybindObj.Callback, false)
			end
		end
	end)

	frame.Destroying:Connect(function()
		c1:Disconnect()
		c2:Disconnect()
	end)

	if registry then
		registry[id] = keybindObj
	end

	return keybindObj
end

return Keybind
