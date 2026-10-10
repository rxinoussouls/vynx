--[[
    Vynx UI Library - Standalone Single File Bundle
    Generated for Roblox Luau execution (gethui / CoreGui)
]]--
local _modules = {}
local _loaded = {}
local function _require(name)
    if _loaded[name] then
        return _loaded[name]
    end
    if _modules[name] then
        _loaded[name] = _modules[name]()
        return _loaded[name]
    end
    error('Module not found: ' .. tostring(name))
end

_modules['Core.Elements'] = function()
local TweenService = game:GetService("TweenService")

local Elements = {}

function Elements.Create(className: string, properties: { [string]: any }?, children: { Instance }?): Instance
	local instance = Instance.new(className)
	if properties then
		for key, value in pairs(properties) do
			(instance :: any)[key] = value
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end
	return instance
end

function Elements.Round(target: Instance, radius: number?): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = target
	return corner
end

function Elements.Stroke(target: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(45, 45, 55)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = target
	return stroke
end

function Elements.Padding(target: Instance, pad: number | { Top: number?, Bottom: number?, Left: number?, Right: number? }): UIPadding
	local padding = Instance.new("UIPadding")
	if typeof(pad) == "number" then
		padding.PaddingTop = UDim.new(0, pad)
		padding.PaddingBottom = UDim.new(0, pad)
		padding.PaddingLeft = UDim.new(0, pad)
		padding.PaddingRight = UDim.new(0, pad)
	elseif typeof(pad) == "table" then
		padding.PaddingTop = UDim.new(0, pad.Top or 0)
		padding.PaddingBottom = UDim.new(0, pad.Bottom or 0)
		padding.PaddingLeft = UDim.new(0, pad.Left or 0)
		padding.PaddingRight = UDim.new(0, pad.Right or 0)
	end
	padding.Parent = target
	return padding
end

function Elements.Tween(target: Instance, info: TweenInfo, properties: { [string]: any }): Tween
	local tween = TweenService:Create(target, info, properties)
	tween:Play()
	return tween
end

return Elements
end

_modules['Core.Theme'] = function()
local TweenService = game:GetService("TweenService")

local Theme = {}

export type ThemeColors = {
	Accent: Color3,
	Background: Color3,
	Secondary: Color3,
	Surface: Color3,
	Border: Color3,
	Text: Color3,
	SubText: Color3,
}

Theme.Presets = {
	Obsidian = {
		Accent = Color3.fromRGB(138, 75, 255),
		Background = Color3.fromRGB(16, 16, 22),
		Secondary = Color3.fromRGB(24, 24, 32),
		Surface = Color3.fromRGB(32, 32, 42),
		Border = Color3.fromRGB(50, 50, 65),
		Text = Color3.fromRGB(245, 245, 250),
		SubText = Color3.fromRGB(155, 155, 170),
	},
	Cyberpunk = {
		Accent = Color3.fromRGB(0, 240, 255),
		Background = Color3.fromRGB(14, 15, 24),
		Secondary = Color3.fromRGB(22, 23, 36),
		Surface = Color3.fromRGB(30, 32, 48),
		Border = Color3.fromRGB(45, 52, 75),
		Text = Color3.fromRGB(245, 250, 255),
		SubText = Color3.fromRGB(140, 160, 185),
	},
	Emerald = {
		Accent = Color3.fromRGB(46, 213, 115),
		Background = Color3.fromRGB(15, 20, 18),
		Secondary = Color3.fromRGB(22, 30, 26),
		Surface = Color3.fromRGB(30, 42, 36),
		Border = Color3.fromRGB(45, 62, 54),
		Text = Color3.fromRGB(240, 250, 245),
		SubText = Color3.fromRGB(150, 175, 162),
	},
	Monochrome = {
		Accent = Color3.fromRGB(255, 255, 255),
		Background = Color3.fromRGB(18, 18, 18),
		Secondary = Color3.fromRGB(28, 28, 28),
		Surface = Color3.fromRGB(38, 38, 38),
		Border = Color3.fromRGB(60, 60, 60),
		Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(160, 160, 160),
	},
}

Theme.Current = Theme.Presets.Obsidian
Theme.Registry = {} :: { [Instance]: { Property: string, Token: string } }

function Theme.Register(instance: Instance, property: string, token: string): Instance
	Theme.Registry[instance] = { Property = property, Token = token }
	local color = (Theme.Current :: any)[token]
	if color then
		(instance :: any)[property] = color
	end

	instance.Destroying:Connect(function()
		Theme.Registry[instance] = nil
	end)
	return instance
end

function Theme.Get(token: string): Color3
	return (Theme.Current :: any)[token] or Color3.fromRGB(255, 255, 255)
end

function Theme.SetTheme(nameOrPalette: string | ThemeColors, duration: number?)
	local palette: ThemeColors
	if typeof(nameOrPalette) == "string" then
		palette = Theme.Presets[nameOrPalette] or Theme.Presets.Obsidian
	else
		palette = nameOrPalette
	end
	Theme.Current = palette

	local tweenInfo = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for instance, binding in pairs(Theme.Registry) do
		if instance and instance.Parent then
			local color = (palette :: any)[binding.Token]
			if color then
				TweenService:Create(instance, tweenInfo, { [binding.Property] = color }):Play()
			end
		else
			Theme.Registry[instance] = nil
		end
	end
end

return Theme
end

_modules['Core.Drag'] = function()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Drag = {}

function Drag.Make(target: GuiObject, handle: GuiObject, smoothness: number?)
	local alpha = smoothness or 0.25
	local dragging = false
	local dragStartPos = Vector2.zero
	local frameStartPos = UDim2.new()
	local targetPos = target.Position

	local dragInput: InputObject? = nil

	local function onInputBegan(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
			frameStartPos = target.Position
			dragInput = input

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragInput = nil
				end
			end)
		end
	end

	handle.InputBegan:Connect(onInputBegan)

	UserInputService.InputChanged:Connect(function(input: InputObject)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
			targetPos = UDim2.new(
				frameStartPos.X.Scale,
				frameStartPos.X.Offset + delta.X,
				frameStartPos.Y.Scale,
				frameStartPos.Y.Offset + delta.Y
			)
		end
	end)

	local connection = RunService.RenderStepped:Connect(function(dt: number)
		if not target.Parent then return end
		if smoothness and smoothness > 0 then
			local currentX = target.Position.X.Offset
			local currentY = target.Position.Y.Offset
			local goalX = targetPos.X.Offset
			local goalY = targetPos.Y.Offset

			local lerpX = currentX + (goalX - currentX) * math.clamp(alpha * (dt * 60), 0, 1)
			local lerpY = currentY + (goalY - currentY) * math.clamp(alpha * (dt * 60), 0, 1)

			target.Position = UDim2.new(targetPos.X.Scale, math.round(lerpX), targetPos.Y.Scale, math.round(lerpY))
		else
			target.Position = targetPos
		end
	end)

	target.Destroying:Connect(function()
		connection:Disconnect()
	end)
end

return Drag
end

_modules['Core.SaveManager'] = function()
local HttpService = game:GetService("HttpService")

local SaveManager = {}

SaveManager.Folder = "vynx"
SaveManager.SubFolder = "configs"
SaveManager.Library = nil

local function getPath(name: string): string
	return string.format("%s/%s/%s.json", SaveManager.Folder, SaveManager.SubFolder, name)
end

function SaveManager:SetLibrary(library: any)
	self.Library = library
end

function SaveManager:InitFolders()
	if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
		if not isfolder(self.Folder) then
			makefolder(self.Folder)
		end
		if not isfolder(self.Folder .. "/" .. self.SubFolder) then
			makefolder(self.Folder .. "/" .. self.SubFolder)
		end
	end
end

function SaveManager:Save(name: string): boolean
	if not self.Library then return false end
	self:InitFolders()

	local data = {
		Toggles = {},
		Options = {},
	}

	for id, toggle in pairs(self.Library.Toggles) do
		data.Toggles[id] = toggle.Value
	end

	for id, option in pairs(self.Library.Options) do
		local val = option.Value
		if typeof(val) == "Color3" then
			data.Options[id] = { Type = "Color3", R = val.R, G = val.G, B = val.B }
		elseif typeof(val) == "EnumItem" then
			data.Options[id] = { Type = "EnumItem", Name = val.Name }
		else
			data.Options[id] = { Type = "Primitive", Value = val }
		end
	end

	local encoded = HttpService:JSONEncode(data)
	if typeof(writefile) == "function" then
		writefile(getPath(name), encoded)
		return true
	end
	return false
end

function SaveManager:Load(name: string): boolean
	if not self.Library then return false end
	local filePath = getPath(name)
	if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" or not isfile(filePath) then
		return false
	end

	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(filePath))
	end)

	if not success or typeof(data) ~= "table" then
		return false
	end

	if data.Toggles then
		for id, val in pairs(data.Toggles) do
			if self.Library.Toggles[id] then
				self.Library.Toggles[id]:SetValue(val)
			end
		end
	end

	if data.Options then
		for id, item in pairs(data.Options) do
			if self.Library.Options[id] then
				if item.Type == "Color3" then
					self.Library.Options[id]:SetValue(Color3.new(item.R, item.G, item.B))
				elseif item.Type == "EnumItem" then
					local key = (Enum.KeyCode :: any)[item.Name]
					if key then
						self.Library.Options[id]:SetValue(key)
					end
				else
					self.Library.Options[id]:SetValue(item.Value)
				end
			end
		end
	end

	return true
end

function SaveManager:BuildConfigSection(tab: any)
	local box = tab:AddRightGroupbox("Configuration")

	local configNameInput = box:AddInput("ConfigName", {
		Text = "Config Name",
		Placeholder = "default",
	})

	box:AddButton({
		Text = "Save Config",
		Func = function()
			local name = configNameInput.Value
			if name and #name > 0 then
				local ok = self:Save(name)
				if self.Library.Notify then
					self.Library:Notify({
						Title = "Config Manager",
						Content = ok and ("Saved config: " .. name) or "Failed to save config",
					})
				end
			end
		end,
	})

	box:AddButton({
		Text = "Load Config",
		Func = function()
			local name = configNameInput.Value
			if name and #name > 0 then
				local ok = self:Load(name)
				if self.Library.Notify then
					self.Library:Notify({
						Title = "Config Manager",
						Content = ok and ("Loaded config: " .. name) or "Config not found",
					})
				end
			end
		end,
	})
end

return SaveManager
end

_modules['Components.Button'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local Button = {}

export type ButtonOptions = {
	Text: string,
	Func: (() -> ())?,
	Callback: (() -> ())?,
	Tooltip: string?,
	DoubleClick: boolean?,
}

function Button.New(parent: GuiObject, options: ButtonOptions)
	local callback = options.Func or options.Callback or function() end
	local lastClickTime = 0

	local btn = Elements.Create("TextButton", {
		Name = (options.Text or "Button") .. "_Btn",
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = options.Text or "Button",
		TextColor3 = Theme.Get("Text"),
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		ClipsDescendants = true,
		Parent = parent,
	}) :: TextButton

	Elements.Round(btn, 6)
	local stroke = Elements.Stroke(btn, Theme.Get("Border"), 1, 0)
	Theme.Register(btn, "BackgroundColor3", "Surface")
	Theme.Register(btn, "TextColor3", "Text")
	Theme.Register(stroke, "Color", "Border")

	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	btn.MouseEnter:Connect(function()
		Elements.Tween(stroke, tweenInfo, { Color = Theme.Get("Accent") })
	end)

	btn.MouseLeave:Connect(function()
		Elements.Tween(stroke, tweenInfo, { Color = Theme.Get("Border") })
	end)

	btn.MouseButton1Click:Connect(function()
		local now = os.clock()
		if options.DoubleClick then
			if (now - lastClickTime) < 0.35 then
				lastClickTime = 0
				task.spawn(callback)
			else
				lastClickTime = now
			end
		else
			-- Quick push click bounce
			Elements.Tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, -2, 0, 26),
			})
			task.delay(0.08, function()
				Elements.Tween(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 0, 0, 28),
				})
			end)
			task.spawn(callback)
		end
	end)

	return btn
end

return Button
end

_modules['Components.Toggle'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

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
end

_modules['Components.Slider'] = function()
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local Slider = {}

export type SliderOptions = {
	Text: string,
	Default: number?,
	Min: number,
	Max: number,
	Rounding: number?,
	Suffix: string?,
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
			self.Value = clamped
			valLabel.Text = tostring(clamped) .. suffix
			local p = (clamped - minVal) / (maxVal - minVal)
			Elements.Tween(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(p, 0, 1, 0),
			})
			task.spawn(self.Callback, clamped)
		end,
	}

	local isDragging = false

	local function updateFromInput(inputPos: Vector2)
		local absPos = track.AbsolutePosition
		local absSize = track.AbsoluteSize
		local relativeX = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
		local val = minVal + (maxVal - minVal) * relativeX
		sliderObj:SetValue(val)
	end

	track.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			updateFromInput(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)

	UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input: InputObject)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInput(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)

	registry[id] = sliderObj
	return sliderObj
end

return Slider
end

_modules['Components.Input'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local Input = {}

export type InputOptions = {
	Text: string,
	Default: string?,
	Placeholder: string?,
	Numeric: boolean?,
	Finished: boolean?,
	Callback: ((string) -> ())?,
}

function Input.New(parent: GuiObject, id: string, options: InputOptions, registry: { [string]: any })
	local currentText = options.Default or ""
	local callback = options.Callback or function() end

	local frame = Elements.Create("Frame", {
		Name = id .. "_Input",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		Parent = parent,
	}) :: Frame

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
			self.Value = newText
			textBox.Text = newText
			task.spawn(self.Callback, newText)
		end,
	}

	textBox.Focused:Connect(function()
		Elements.Tween(stroke, TweenInfo.new(0.15), { Color = Theme.Get("Accent") })
	end)

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

	if not options.Finished then
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
end

_modules['Components.Dropdown'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local Dropdown = {}

export type DropdownOptions = {
	Text: string,
	Values: { string },
	Default: any?,
	Multi: boolean?,
	Callback: ((any) -> ())?,
}

function Dropdown.New(parent: GuiObject, id: string, options: DropdownOptions, registry: { [string]: any })
	local values = options.Values or {}
	local isMulti = options.Multi or false
	local callback = options.Callback or function() end
	local isOpen = false

	local currentValue: any
	if isMulti then
		currentValue = {}
		if typeof(options.Default) == "table" then
			for _, v in ipairs(options.Default) do
				currentValue[v] = true
			end
		end
	else
		currentValue = options.Default or values[1] or ""
	end

	local frame = Elements.Create("Frame", {
		Name = id .. "_Dropdown",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		ZIndex = 5,
		Parent = parent,
	}) :: Frame

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Text or id,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		ZIndex = 5,
		Parent = frame,
	}) :: TextLabel
	Theme.Register(label, "TextColor3", "Text")

	local box = Elements.Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5,
		Parent = frame,
	}) :: TextButton
	Elements.Round(box, 6)
	local boxStroke = Elements.Stroke(box, Theme.Get("Border"), 1, 0)
	Theme.Register(box, "BackgroundColor3", "Surface")
	Theme.Register(boxStroke, "Color", "Border")

	local valLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		ZIndex = 5,
		Parent = box,
	}) :: TextLabel
	Theme.Register(valLabel, "TextColor3", "Text")

	local arrow = Elements.Create("TextLabel", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -22, 0, 0),
		BackgroundTransparency = 1,
		Text = "v",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		ZIndex = 5,
		Parent = box,
	}) :: TextLabel
	Theme.Register(arrow, "TextColor3", "SubText")

	local listFrame = Elements.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 1, 4),
		BackgroundColor3 = Theme.Get("Secondary"),
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Get("Accent"),
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 20,
		Parent = box,
	}) :: ScrollingFrame
	Elements.Round(listFrame, 6)
	local listStroke = Elements.Stroke(listFrame, Theme.Get("Border"), 1, 0)
	Theme.Register(listFrame, "BackgroundColor3", "Secondary")
	Theme.Register(listStroke, "Color", "Border")

	local layout = Elements.Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = listFrame,
	}) :: UIListLayout
	Elements.Padding(listFrame, 4)

	local function getDisplayText(): string
		if isMulti then
			local active = {}
			for item, selected in pairs(currentValue) do
				if selected then
					table.insert(active, tostring(item))
				end
			end
			return #active > 0 and table.concat(active, ", ") or "None"
		else
			return tostring(currentValue)
		end
	end

	valLabel.Text = getDisplayText()

	local dropdownObj = {
		Value = currentValue,
		Values = values,
		Callback = callback,
		SetValue = function(self: any, newVal: any)
			self.Value = newVal
			currentValue = newVal
			valLabel.Text = getDisplayText()
			task.spawn(self.Callback, newVal)
		end,
		SetValues = function(self: any, newValues: { string })
			self.Values = newValues
			-- rebuild items
		end,
	}

	local function refreshItems()
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for _, itemVal in ipairs(dropdownObj.Values) do
			local isSelected = isMulti and (currentValue[itemVal] == true) or (currentValue == itemVal)
			local itemBtn = Elements.Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundColor3 = isSelected and Theme.Get("Surface") or Theme.Get("Secondary"),
				BackgroundTransparency = isSelected and 0 or 1,
				Text = "  " .. itemVal,
				TextColor3 = isSelected and Theme.Get("Accent") or Theme.Get("Text"),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				AutoButtonColor = false,
				ZIndex = 21,
				Parent = listFrame,
			}) :: TextButton
			Elements.Round(itemBtn, 4)

			itemBtn.MouseButton1Click:Connect(function()
				if isMulti then
					currentValue[itemVal] = not currentValue[itemVal]
					dropdownObj:SetValue(currentValue)
					refreshItems()
				else
					dropdownObj:SetValue(itemVal)
					isOpen = false
					listFrame.Visible = false
					arrow.Text = "v"
					frame.ZIndex = 5
				end
			end)
		end

		local totalHeight = math.min(#dropdownObj.Values * 26 + 8, 140)
		listFrame.Size = UDim2.new(1, 0, 0, totalHeight)
		listFrame.CanvasSize = UDim2.new(0, 0, 0, #dropdownObj.Values * 26 + 8)
	end

	box.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		arrow.Text = isOpen and "^" or "v"
		if isOpen then
			frame.ZIndex = 50
			box.ZIndex = 50
			refreshItems()
			listFrame.Visible = true
		else
			frame.ZIndex = 5
			box.ZIndex = 5
			listFrame.Visible = false
		end
	end)

	registry[id] = dropdownObj
	return dropdownObj
end

return Dropdown
end

_modules['Components.Colorpicker'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local Colorpicker = {}

export type ColorpickerOptions = {
	Text: string,
	Default: Color3?,
	Transparency: number?,
	Callback: ((Color3, number) -> ())?,
}

function Colorpicker.New(parent: GuiObject, id: string, options: ColorpickerOptions, registry: { [string]: any })
	local currentColor = options.Default or Color3.fromRGB(138, 75, 255)
	local currentAlpha = options.Transparency or 0
	local callback = options.Callback or function() end
	local isOpen = false

	local frame = Elements.Create("Frame", {
		Name = id .. "_Colorpicker",
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		ZIndex = 6,
		Parent = parent,
	}) :: Frame

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Text or id,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		ZIndex = 6,
		Parent = frame,
	}) :: TextLabel
	Theme.Register(label, "TextColor3", "Text")

	local previewBtn = Elements.Create("TextButton", {
		Size = UDim2.new(0, 32, 0, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -2, 0.5, 0),
		BackgroundColor3 = currentColor,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 6,
		Parent = frame,
	}) :: TextButton
	Elements.Round(previewBtn, 4)
	local previewStroke = Elements.Stroke(previewBtn, Theme.Get("Border"), 1, 0)
	Theme.Register(previewStroke, "Color", "Border")

	-- Palette Popover
	local popover = Elements.Create("Frame", {
		Size = UDim2.new(0, 160, 0, 110),
		Position = UDim2.new(1, -160, 1, 4),
		BackgroundColor3 = Theme.Get("Secondary"),
		Visible = false,
		ZIndex = 30,
		Parent = previewBtn,
	}) :: Frame
	Elements.Round(popover, 6)
	local popoverStroke = Elements.Stroke(popover, Theme.Get("Border"), 1, 0)
	Theme.Register(popover, "BackgroundColor3", "Secondary")
	Theme.Register(popoverStroke, "Color", "Border")
	Elements.Padding(popover, 8)

	-- Swatches
	local swatches = {
		Color3.fromRGB(255, 75, 75),
		Color3.fromRGB(255, 150, 50),
		Color3.fromRGB(255, 220, 50),
		Color3.fromRGB(60, 220, 120),
		Color3.fromRGB(50, 180, 255),
		Color3.fromRGB(138, 75, 255),
		Color3.fromRGB(255, 100, 200),
		Color3.fromRGB(255, 255, 255),
	}

	local swatchGrid = Elements.Create("UIGridLayout", {
		CellSize = UDim2.new(0, 32, 0, 24),
		CellPadding = UDim2.new(0, 5, 0, 5),
		Parent = popover,
	})

	local colorpickerObj = {
		Value = currentColor,
		Transparency = currentAlpha,
		Callback = callback,
		SetValue = function(self: any, newCol: Color3, newAlpha: number?)
			self.Value = newCol
			if newAlpha then
				self.Transparency = newAlpha
			end
			previewBtn.BackgroundColor3 = newCol
			task.spawn(self.Callback, newCol, self.Transparency)
		end,
	}

	for _, col in ipairs(swatches) do
		local sBtn = Elements.Create("TextButton", {
			BackgroundColor3 = col,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 31,
			Parent = popover,
		}) :: TextButton
		Elements.Round(sBtn, 4)
		Elements.Stroke(sBtn, Color3.fromRGB(30, 30, 40), 1, 0)
		sBtn.MouseButton1Click:Connect(function()
			colorpickerObj:SetValue(col)
		end)
	end

	previewBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		popover.Visible = isOpen
		frame.ZIndex = isOpen and 50 or 6
	end)

	registry[id] = colorpickerObj
	return colorpickerObj
end

return Colorpicker
end

_modules['Components.Keybind'] = function()
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

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

	local keybindObj = {
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
end

_modules['Components.Notification'] = function()
local TweenService = game:GetService("TweenService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local Notification = {}

local holder: Frame? = nil

function Notification.Init(gui: ScreenGui)
	if holder then return end
	holder = Elements.Create("Frame", {
		Name = "NotificationHolder",
		Size = UDim2.new(0, 300, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -10),
		BackgroundTransparency = 1,
		ZIndex = 100,
		Parent = gui,
	}) :: Frame

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 8),
		Parent = holder,
	})
end

export type NotifyInfo = {
	Title: string?,
	Content: string,
	Duration: number?,
}

function Notification.Show(info: NotifyInfo)
	if not holder then return end

	local duration = info.Duration or 3.5
	local toast = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = Theme.Get("Secondary"),
		Position = UDim2.new(1, 320, 0, 0), -- starts offscreen right
		ZIndex = 101,
		Parent = holder,
	}) :: Frame
	Elements.Round(toast, 6)
	local stroke = Elements.Stroke(toast, Theme.Get("Border"), 1, 0)
	Theme.Register(toast, "BackgroundColor3", "Secondary")
	Theme.Register(stroke, "Color", "Border")
	Elements.Padding(toast, { Top = 8, Bottom = 6, Left = 12, Right = 12 })

	local titleLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = info.Title or "Notification",
		TextColor3 = Theme.Get("Accent"),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 102,
		Parent = toast,
	}) :: TextLabel
	Theme.Register(titleLabel, "TextColor3", "Accent")

	local contentLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = info.Content,
		TextColor3 = Theme.Get("Text"),
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 102,
		Parent = toast,
	}) :: TextLabel
	Theme.Register(contentLabel, "TextColor3", "Text")

	local barBg = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = Theme.Get("Surface"),
		ZIndex = 102,
		Parent = toast,
	}) :: Frame

	local progress = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.Get("Accent"),
		ZIndex = 103,
		Parent = barBg,
	}) :: Frame
	Theme.Register(progress, "BackgroundColor3", "Accent")

	-- Animate In
	Elements.Tween(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
	})

	-- Progress Bar Countdown
	Elements.Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 1, 0),
	})

	task.delay(duration, function()
		if not toast.Parent then return end
		-- Animate Out
		local outTween = Elements.Tween(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 320, 0, 0),
		})
		outTween.Completed:Connect(function()
			toast:Destroy()
		end)
	end)
end

return Notification
end

_modules['Components.Groupbox'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local Button = _require("Components.Button")
local Toggle = _require("Components.Toggle")
local Slider = _require("Components.Slider")
local Dropdown = _require("Components.Dropdown")
local Colorpicker = _require("Components.Colorpicker")
local Keybind = _require("Components.Keybind")
local Input = _require("Components.Input")

local Groupbox = {}

function Groupbox.New(parent: GuiObject, title: string, library: any)
	local box = Elements.Create("Frame", {
		Name = title .. "_Groupbox",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Get("Secondary"),
		ZIndex = 2,
		Parent = parent,
	}) :: Frame
	Elements.Round(box, 6)
	local boxStroke = Elements.Stroke(box, Theme.Get("Border"), 1, 0)
	Theme.Register(box, "BackgroundColor3", "Secondary")
	Theme.Register(boxStroke, "Color", "Border")
	Elements.Padding(box, { Top = 10, Bottom = 10, Left = 12, Right = 12 })

	-- Section Header
	local header = Elements.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = string.upper(title),
		TextColor3 = Theme.Get("Accent"),
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = box,
	}) :: TextLabel
	Theme.Register(header, "TextColor3", "Accent")

	-- Children container
	local container = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = box,
	}) :: Frame

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = container,
	})

	local boxObj = {
		Frame = box,
		Container = container,
		AddToggle = function(self: any, id: string, options: any)
			return Toggle.New(container, id, options, library.Toggles)
		end,
		AddButton = function(self: any, options: any)
			return Button.New(container, options)
		end,
		AddSlider = function(self: any, id: string, options: any)
			return Slider.New(container, id, options, library.Options)
		end,
		AddDropdown = function(self: any, id: string, options: any)
			return Dropdown.New(container, id, options, library.Options)
		end,
		AddColorpicker = function(self: any, id: string, options: any)
			return Colorpicker.New(container, id, options, library.Options)
		end,
		AddKeybind = function(self: any, id: string, options: any)
			return Keybind.New(container, id, options, library.Options)
		end,
		AddInput = function(self: any, id: string, options: any)
			return Input.New(container, id, options, library.Options)
		end,
		AddDivider = function(self: any)
			local div = Elements.Create("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Get("Border"),
				BorderSizePixel = 0,
				Parent = container,
			})
			Theme.Register(div, "BackgroundColor3", "Border")
			return div
		end,
		AddLabel = function(self: any, text: string)
			local lbl = Elements.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Get("Text"),
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})
			Theme.Register(lbl, "TextColor3", "Text")
			return lbl
		end,
	}

	return boxObj
end

return Groupbox
end

_modules['Components.Tab'] = function()
local Elements = _require("Core.Elements")
local Groupbox = _require("Components.Groupbox")

local Tab = {}

function Tab.New(parent: GuiObject, name: string, library: any)
	local page = Elements.Create("Frame", {
		Name = name .. "_Page",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	}) :: Frame

	local leftColumn = Elements.Create("ScrollingFrame", {
		Name = "LeftColumn",
		Size = UDim2.new(0.5, -6, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = page,
	}) :: ScrollingFrame

	local leftLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = leftColumn,
	})

	local rightColumn = Elements.Create("ScrollingFrame", {
		Name = "RightColumn",
		Size = UDim2.new(0.5, -6, 1, 0),
		Position = UDim2.new(0.5, 6, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = page,
	}) :: ScrollingFrame

	local rightLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = rightColumn,
	})

	local tabObj = {
		Name = name,
		Page = page,
		AddLeftGroupbox = function(self: any, title: string)
			return Groupbox.New(leftColumn, title, library)
		end,
		AddRightGroupbox = function(self: any, title: string)
			return Groupbox.New(rightColumn, title, library)
		end,
		Show = function(self: any)
			page.Visible = true
		end,
		Hide = function(self: any)
			page.Visible = false
		end,
	}

	return tabObj
end

return Tab
end

_modules['Components.Window'] = function()
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Drag = _require("Core.Drag")
local Tab = _require("Components.Tab")

local Window = {}

export type WindowOptions = {
	Title: string,
	SubTitle: string?,
	Size: UDim2?,
	TabWidth: number?,
	Keybind: Enum.KeyCode?,
}

function Window.New(gui: ScreenGui, options: WindowOptions, library: any)
	local windowSize = options.Size or UDim2.fromOffset(600, 420)
	local tabWidth = options.TabWidth or 130
	local toggleKey = options.Keybind or Enum.KeyCode.RightControl
	local isVisible = true

	local main = Elements.Create("Frame", {
		Name = "MainWindow",
		Size = windowSize,
		Position = UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2),
		BackgroundColor3 = Theme.Get("Background"),
		ClipsDescendants = false,
		Parent = gui,
	}) :: Frame
	Elements.Round(main, 8)
	local mainStroke = Elements.Stroke(main, Theme.Get("Border"), 1, 0)
	Theme.Register(main, "BackgroundColor3", "Background")
	Theme.Register(mainStroke, "Color", "Border")

	-- Topbar
	local topbar = Elements.Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = main,
	}) :: Frame

	-- Drag
	Drag.Make(main, topbar, 0.25)

	-- Title and SubTitle
	local titleLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "vynx",
		TextColor3 = Theme.Get("Text"),
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	}) :: TextLabel
	Theme.Register(titleLabel, "TextColor3", "Text")

	if options.SubTitle then
		local subLabel = Elements.Create("TextLabel", {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Position = UDim2.new(0, 14, 0, 0),
			BackgroundTransparency = 1,
			Text = " / " .. options.SubTitle,
			TextColor3 = Theme.Get("SubText"),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = topbar,
		}) :: TextLabel
		Theme.Register(subLabel, "TextColor3", "SubText")
		titleLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			subLabel.Position = UDim2.new(0, 14 + titleLabel.AbsoluteSize.X + 4, 0, 0)
		end)
	end

	-- Control Buttons
	local minBtn = Elements.Create("TextButton", {
		Size = UDim2.new(0, 24, 0, 24),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Text = "-",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		Parent = topbar,
	}) :: TextButton

	-- Topbar Divider
	local topDivider = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = Theme.Get("Border"),
		BorderSizePixel = 0,
		Parent = main,
	}) :: Frame
	Theme.Register(topDivider, "BackgroundColor3", "Border")

	-- Sidebar (Tab List)
	local sidebar = Elements.Create("ScrollingFrame", {
		Name = "Sidebar",
		Size = UDim2.new(0, tabWidth, 1, -37),
		Position = UDim2.new(0, 0, 0, 37),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = main,
	}) :: ScrollingFrame
	Elements.Padding(sidebar, { Top = 10, Bottom = 10, Left = 8, Right = 8 })

	local tabListLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = sidebar,
	})

	-- Sidebar Divider
	local sideDivider = Elements.Create("Frame", {
		Size = UDim2.new(0, 1, 1, -37),
		Position = UDim2.new(0, tabWidth, 0, 37),
		BackgroundColor3 = Theme.Get("Border"),
		BorderSizePixel = 0,
		Parent = main,
	}) :: Frame
	Theme.Register(sideDivider, "BackgroundColor3", "Border")

	-- Pages Container
	local pagesHolder = Elements.Create("Frame", {
		Name = "PagesHolder",
		Size = UDim2.new(1, -tabWidth - 1, 1, -37),
		Position = UDim2.new(0, tabWidth + 1, 0, 37),
		BackgroundTransparency = 1,
		Parent = main,
	}) :: Frame
	Elements.Padding(pagesHolder, 12)

	local tabs = {}
	local currentTab: any = nil

	local windowObj = {
		Main = main,
		AddTab = function(self: any, name: string)
			local newTab = Tab.New(pagesHolder, name, library)

			local tabBtn = Elements.Create("TextButton", {
				Name = name .. "_TabBtn",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = Theme.Get("Surface"),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.Get("SubText"),
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				AutoButtonColor = false,
				Parent = sidebar,
			}) :: TextButton
			Elements.Round(tabBtn, 5)

			local function selectTab()
				if currentTab == newTab then return end
				for _, t in ipairs(tabs) do
					t.TabObj:Hide()
					Elements.Tween(t.Btn, TweenInfo.new(0.15), {
						BackgroundTransparency = 1,
						TextColor3 = Theme.Get("SubText"),
					})
				end
				currentTab = newTab
				newTab:Show()
				Elements.Tween(tabBtn, TweenInfo.new(0.15), {
					BackgroundTransparency = 0,
					TextColor3 = Theme.Get("Accent"),
				})
			end

			tabBtn.MouseButton1Click:Connect(selectTab)
			table.insert(tabs, { Name = name, TabObj = newTab, Btn = tabBtn })

			if #tabs == 1 then
				selectTab()
			end

			return newTab
		end,
		Toggle = function(self: any, visible: boolean?)
			if visible ~= nil then
				isVisible = visible
			else
				isVisible = not isVisible
			end
			main.Visible = isVisible
		end,
	}

	minBtn.MouseButton1Click:Connect(function()
		windowObj:Toggle(false)
	end)

	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if not processed and input.KeyCode == toggleKey then
			windowObj:Toggle()
		end
	end)

	return windowObj
end

return Window
end

_modules['Main'] = function()
local CoreGui = game:GetService("CoreGui")

local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local SaveManager = _require("Core.SaveManager")
local Window = _require("Components.Window")
local Notification = _require("Components.Notification")

local Library = {
	Toggles = {} :: { [string]: any },
	Options = {} :: { [string]: any },
	Theme = Theme,
	SaveManager = SaveManager,
	ScreenGui = nil :: ScreenGui?,
	ActiveWindow = nil :: any,
}

SaveManager:SetLibrary(Library)

local function getGuiParent(): Instance
	if typeof(gethui) == "function" then
		return gethui()
	end
	return CoreGui
end

function Library:InitGui(): ScreenGui
	if self.ScreenGui then
		return self.ScreenGui
	end

	local gui = Elements.Create("ScreenGui", {
		Name = "vynx_" .. string.sub(tostring(math.random()), 3, 8),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = getGuiParent(),
	}) :: ScreenGui

	if typeof(syn) == "table" and typeof((syn :: any).protect_gui) == "function" then
		(syn :: any).protect_gui(gui)
	end

	self.ScreenGui = gui
	Notification.Init(gui)
	return gui
end

function Library:CreateWindow(options: any)
	local gui = self:InitGui()
	local win = Window.New(gui, options, self)
	self.ActiveWindow = win
	return win
end

function Library:Notify(info: { Title: string?, Content: string, Duration: number? })
	if not self.ScreenGui then
		self:InitGui()
	end
	Notification.Show(info)
end

function Library:SetTheme(nameOrPalette: any)
	Theme.SetTheme(nameOrPalette)
end

function Library:Unload()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
		self.ScreenGui = nil
	end
	table.clear(self.Toggles)
	table.clear(self.Options)
end

return Library
end

return _require('Main')