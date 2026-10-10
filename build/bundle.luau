--[[
    Vynx UI Library - Standalone Single File Bundle (Vynx 2)
    Compatible with all Luau executors and Roblox Studio
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

function Elements.Create(className, properties, children)
	local instance = Instance.new(className)
	local targetParent = nil

	if properties then
		for key, value in pairs(properties) do
			if key == "Parent" then
				targetParent = value
			else
				instance[key] = value
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end

	if targetParent then
		instance.Parent = targetParent
	end

	return instance
end

function Elements.Round(target, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = target
	return corner
end

function Elements.Stroke(target, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(45, 45, 55)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = target
	return stroke
end

function Elements.Padding(target, pad)
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

function Elements.Scale(target, scale)
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = scale or 1
	uiScale.Parent = target
	return uiScale
end

function Elements.Gradient(target, colors, rotation, transparency)
	local grad = Instance.new("UIGradient")
	if colors then grad.Color = colors end
	if rotation then grad.Rotation = rotation end
	if transparency then grad.Transparency = transparency end
	grad.Parent = target
	return grad
end

function Elements.Tween(target, info, properties)
	local tween = TweenService:Create(target, info, properties)
	tween:Play()
	return tween
end

return Elements
end

_modules['Core.Theme'] = function()
local TweenService = game:GetService("TweenService")

local Theme = {}

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
Theme.ChangedEvent = Instance.new("BindableEvent")
Theme.Changed = Theme.ChangedEvent.Event

Theme.Registry = setmetatable({}, { __mode = "k" })

function Theme.Register(instance, property, token)
	if not Theme.Registry[instance] then
		Theme.Registry[instance] = {}
	end
	Theme.Registry[instance][property] = token

	local color = Theme.Current[token]
	if color then
		instance[property] = color
	end
	return instance
end

function Theme.Get(token)
	return Theme.Current[token] or Color3.fromRGB(255, 255, 255)
end

function Theme.SetTheme(nameOrPalette, duration)
	local palette
	if typeof(nameOrPalette) == "string" then
		palette = Theme.Presets[nameOrPalette] or Theme.Presets.Obsidian
	else
		palette = nameOrPalette
	end
	Theme.Current = palette

	local tweenInfo = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for instance, propMap in pairs(Theme.Registry) do
		if instance and instance.Parent then
			local goals = {}
			for prop, token in pairs(propMap) do
				local color = palette[token]
				if color then
					goals[prop] = color
				end
			end
			if next(goals) ~= nil then
				TweenService:Create(instance, tweenInfo, goals):Play()
			end
		end
	end

	Theme.ChangedEvent:Fire(palette)
end

return Theme
end

_modules['Core.Maid'] = function()
local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({
		Tasks = {},
	}, Maid)
end

function Maid:Give(task)
	table.insert(self.Tasks, task)
	return task
end

function Maid:Clean()
	for _, task in ipairs(self.Tasks) do
		if typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif typeof(task) == "function" then
			task()
		elseif typeof(task) == "Instance" then
			task:Destroy()
		elseif typeof(task) == "table" and typeof(task.Destroy) == "function" then
			task:Destroy()
		end
	end
	table.clear(self.Tasks)
end

function Maid:Destroy()
	self:Clean()
end

return Maid
end

_modules['Core.Tooltip'] = function()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local Tooltip = {}

local tooltipFrame = nil
local tooltipLabel = nil
local activeTarget = nil
local hoverTime = 0
local isHovering = false
local connections = {}

function Tooltip.Init(gui)
	if tooltipFrame and tooltipFrame.Parent then return end

	tooltipFrame = Elements.Create("Frame", {
		Name = "VynxTooltip",
		Size = UDim2.new(0, 0, 0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Get("Secondary"),
		Visible = false,
		ZIndex = 500,
		Parent = gui,
	})
	Elements.Round(tooltipFrame, 4)
	local stroke = Elements.Stroke(tooltipFrame, Theme.Get("Border"), 1, 0)
	Theme.Register(tooltipFrame, "BackgroundColor3", "Secondary")
	Theme.Register(stroke, "Color", "Border")
	Elements.Padding(tooltipFrame, { Top = 3, Bottom = 3, Left = 8, Right = 8 })

	tooltipLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		TextColor3 = Theme.Get("Text"),
		TextSize = 11,
		Font = Enum.Font.GothamMedium,
		ZIndex = 501,
		Parent = tooltipFrame,
	})
	Theme.Register(tooltipLabel, "TextColor3", "Text")

	local c1 = UserInputService.InputChanged:Connect(function(input)
		if isHovering and tooltipFrame and tooltipFrame.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = UserInputService:GetMouseLocation()
			tooltipFrame.Position = UDim2.fromOffset(mousePos.X + 12, mousePos.Y + 12)
		end
	end)

	local c2 = RunService.RenderStepped:Connect(function(dt)
		if isHovering and activeTarget and not (tooltipFrame and tooltipFrame.Visible) then
			hoverTime = hoverTime + dt
			if hoverTime >= 0.35 and tooltipFrame then
				local mousePos = UserInputService:GetMouseLocation()
				tooltipFrame.Position = UDim2.fromOffset(mousePos.X + 12, mousePos.Y + 12)
				tooltipFrame.Visible = true
			end
		end
	end)

	table.insert(connections, c1)
	table.insert(connections, c2)
end

function Tooltip.Attach(target, text)
	target.MouseEnter:Connect(function()
		if not tooltipFrame or not tooltipLabel then return end
		activeTarget = target
		hoverTime = 0
		isHovering = true
		tooltipLabel.Text = text
	end)

	target.MouseLeave:Connect(function()
		if activeTarget == target then
			isHovering = false
			activeTarget = nil
			hoverTime = 0
			if tooltipFrame then
				tooltipFrame.Visible = false
			end
		end
	end)
end

function Tooltip.Clean()
	for _, c in ipairs(connections) do
		c:Disconnect()
	end
	table.clear(connections)
	if tooltipFrame then
		tooltipFrame:Destroy()
		tooltipFrame = nil
		tooltipLabel = nil
	end
	activeTarget = nil
	isHovering = false
	hoverTime = 0
end

return Tooltip
end

_modules['Core.Drag'] = function()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Drag = {}

function Drag.Make(target, handle, smoothness, maid)
	local alpha = smoothness or 0.25
	local dragging = false
	local dragStartPos = Vector2.zero
	local frameStartPos = UDim2.new()
	local targetPos = target.Position

	local dragInput = nil

	local function clampToScreen(pos)
		local camera = Workspace.CurrentCamera
		local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
		local size = target.AbsoluteSize
		local anchor = target.AnchorPoint

		local absX = (pos.X.Scale * viewport.X) + pos.X.Offset
		local absY = (pos.Y.Scale * viewport.Y) + pos.Y.Offset

		local minX = anchor.X * size.X
		local maxX = viewport.X - ((1 - anchor.X) * size.X)
		local minY = anchor.Y * size.Y
		local maxY = viewport.Y - ((1 - anchor.Y) * size.Y)

		local clampedX = math.clamp(absX, minX, math.max(minX, maxX))
		local clampedY = math.clamp(absY, minY, math.max(minY, maxY))

		return UDim2.fromOffset(clampedX, clampedY)
	end

	local c1 = handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
			frameStartPos = target.Position
			dragInput = input

			local cEnd
			cEnd = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragInput = nil
					cEnd:Disconnect()
				end
			end)
		end
	end)

	local c2 = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
			local proposed = UDim2.new(
				frameStartPos.X.Scale,
				frameStartPos.X.Offset + delta.X,
				frameStartPos.Y.Scale,
				frameStartPos.Y.Offset + delta.Y
			)
			targetPos = clampToScreen(proposed)
		end
	end)

	local c3 = RunService.RenderStepped:Connect(function(dt)
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

	if maid then
		maid:Give(c1)
		maid:Give(c2)
		maid:Give(c3)
	end

	target.Destroying:Connect(function()
		c1:Disconnect()
		c2:Disconnect()
		c3:Disconnect()
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
SaveManager.IgnoreIndexes = { ["ConfigName"] = true }

local function sanitize(name)
	local clean = string.gsub(name, "[^%w%-_]", "")
	return clean ~= "" and clean or "default"
end

local function getPath(name)
	return string.format("%s/%s/%s.json", SaveManager.Folder, SaveManager.SubFolder, sanitize(name))
end

function SaveManager:SetLibrary(library)
	self.Library = library
end

function SaveManager:SetIgnoreIndexes(indexes)
	for _, idx in ipairs(indexes) do
		self.IgnoreIndexes[idx] = true
	end
end

function SaveManager:InitFolders()
	if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
		pcall(function()
			if not isfolder(self.Folder) then
				makefolder(self.Folder)
			end
			if not isfolder(self.Folder .. "/" .. self.SubFolder) then
				makefolder(self.Folder .. "/" .. self.SubFolder)
			end
		end)
	end
end

function SaveManager:Save(name)
	if not self.Library then return false end
	self:InitFolders()

	local data = {
		Toggles = {},
		Options = {},
	}

	for id, toggle in pairs(self.Library.Toggles) do
		if not self.IgnoreIndexes[id] then
			data.Toggles[id] = toggle.Value
		end
	end

	for id, option in pairs(self.Library.Options) do
		if not self.IgnoreIndexes[id] then
			local val = option.Value
			if typeof(val) == "Color3" then
				data.Options[id] = {
					Type = "Color3",
					R = val.R,
					G = val.G,
					B = val.B,
					Transparency = option.Transparency or 0,
				}
			elseif typeof(val) == "EnumItem" then
				data.Options[id] = {
					Type = "EnumItem",
					Name = val.Name,
					Mode = option.Mode or "Toggle",
				}
			else
				data.Options[id] = { Type = "Primitive", Value = val }
			end
		end
	end

	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if ok and typeof(writefile) == "function" then
		local writeOk = pcall(function()
			writefile(getPath(name), encoded)
		end)
		return writeOk
	end
	return false
end

function SaveManager:Load(name)
	if not self.Library then return false end
	local filePath = getPath(name)

	if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then
		return false
	end

	local existsOk, exists = pcall(function() return isfile(filePath) end)
	if not existsOk or not exists then return false end

	local readOk, content = pcall(function() return readfile(filePath) end)
	if not readOk or typeof(content) ~= "string" then return false end

	local decodeOk, data = pcall(function() return HttpService:JSONDecode(content) end)
	if not decodeOk or typeof(data) ~= "table" then return false end

	if data.Toggles then
		for id, val in pairs(data.Toggles) do
			if self.Library.Toggles[id] and not self.IgnoreIndexes[id] then
				self.Library.Toggles[id]:SetValue(val)
			end
		end
	end

	if data.Options then
		for id, item in pairs(data.Options) do
			if self.Library.Options[id] and not self.IgnoreIndexes[id] then
				if item.Type == "Color3" then
					self.Library.Options[id]:SetValue(Color3.new(item.R, item.G, item.B), item.Transparency or 0)
				elseif item.Type == "EnumItem" then
					local key = Enum.KeyCode[item.Name]
					if key then
						self.Library.Options[id]:SetValue(key)
						if item.Mode and self.Library.Options[id].SetMode then
							self.Library.Options[id]:SetMode(item.Mode)
						end
					end
				else
					self.Library.Options[id]:SetValue(item.Value)
				end
			end
		end
	end

	return true
end

function SaveManager:DeleteConfig(name)
	local filePath = getPath(name)
	if typeof(delfile) == "function" and typeof(isfile) == "function" and isfile(filePath) then
		local ok = pcall(function() delfile(filePath) end)
		return ok
	end
	return false
end

function SaveManager:ListConfigs()
	local configs = {}
	if typeof(listfiles) == "function" and typeof(isfolder) == "function" then
		self:InitFolders()
		local folderPath = self.Folder .. "/" .. self.SubFolder
		local ok, files = pcall(function() return listfiles(folderPath) end)
		if ok and typeof(files) == "table" then
			for _, file in ipairs(files) do
				local match = string.match(file, "([^/\\]+)%.json$")
				if match then
					table.insert(configs, match)
				end
			end
		end
	end
	return configs
end

function SaveManager:SetAutoLoad(name)
	local autoPath = self.Folder .. "/autoload.txt"
	if typeof(writefile) == "function" then
		pcall(function() writefile(autoPath, sanitize(name)) end)
	end
end

function SaveManager:CheckAutoLoad()
	local autoPath = self.Folder .. "/autoload.txt"
	if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(autoPath) then
		local ok, name = pcall(function() return readfile(autoPath) end)
		if ok and name and name ~= "" then
			self:Load(name)
		end
	end
end

function SaveManager:BuildConfigSection(tab)
	local box = tab:AddRightGroupbox("Configuration")

	local configNameInput = box:AddInput("ConfigName", {
		Text = "Config Name",
		Placeholder = "default",
	})
	self.IgnoreIndexes["ConfigName"] = true

	local existingConfigs = self:ListConfigs()
	if #existingConfigs == 0 then
		table.insert(existingConfigs, "default")
	end

	local configDropdown = box:AddDropdown("ConfigSelect", {
		Text = "Saved Configs",
		Values = existingConfigs,
		Default = existingConfigs[1] or "default",
		Callback = function(val)
			configNameInput:SetValue(val)
		end,
	})
	self.IgnoreIndexes["ConfigSelect"] = true

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
						Type = ok and "Success" or "Error",
					})
				end
				configDropdown:SetValues(self:ListConfigs())
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
						Content = ok and ("Loaded config: " .. name) or "Config file not found",
						Type = ok and "Success" or "Error",
					})
				end
			end
		end,
	})

	box:AddButton({
		Text = "Delete Config",
		DoubleClick = true,
		Func = function()
			local name = configNameInput.Value
			if name and #name > 0 then
				local ok = self:DeleteConfig(name)
				if self.Library.Notify then
					self.Library:Notify({
						Title = "Config Manager",
						Content = ok and ("Deleted config: " .. name) or "Failed to delete config",
						Type = ok and "Warn" or "Error",
					})
				end
				configDropdown:SetValues(self:ListConfigs())
			end
		end,
	})
end

return SaveManager
end

_modules['Components.Popover'] = function()
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Elements = _require("Core.Elements")

local Popover = {}

local popoverLayer = nil
local activeContent = nil
local activeAnchor = nil
local closeCallback = nil
local inputConnection = nil

function Popover.Init(gui, maid)
	if popoverLayer and popoverLayer.Parent then return end

	popoverLayer = Elements.Create("Frame", {
		Name = "VynxPopoverLayer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1000,
		Parent = gui,
	})

	if inputConnection then
		inputConnection:Disconnect()
	end

	inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
		if not activeContent or not activeAnchor then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local pos = Vector2.new(input.Position.X, input.Position.Y)

			local cPos = activeContent.AbsolutePosition
			local cSize = activeContent.AbsoluteSize
			local inContent = pos.X >= cPos.X and pos.X <= cPos.X + cSize.X and pos.Y >= cPos.Y and pos.Y <= cPos.Y + cSize.Y

			local aPos = activeAnchor.AbsolutePosition
			local aSize = activeAnchor.AbsoluteSize
			local inAnchor = pos.X >= aPos.X and pos.X <= aPos.X + aSize.X and pos.Y >= aPos.Y and pos.Y <= aPos.Y + aSize.Y

			if not inContent and not inAnchor then
				Popover.Close()
			end
		end
	end)

	if maid then
		maid:Give(inputConnection)
	end
end

function Popover.Open(content, anchor, onClose)
	if not popoverLayer then return end
	if activeContent == content then
		Popover.Close()
		return
	end

	Popover.Close()

	activeContent = content
	activeAnchor = anchor
	closeCallback = onClose

	content.Parent = popoverLayer
	content.Visible = true

	local aPos = anchor.AbsolutePosition
	local aSize = anchor.AbsoluteSize
	local cSize = content.AbsoluteSize
	local cam = Workspace.CurrentCamera
	local viewSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)

	local targetX = aPos.X
	if targetX + cSize.X > viewSize.X - 10 then
		targetX = viewSize.X - cSize.X - 10
	end

	local targetY = aPos.Y + aSize.Y + 4
	if targetY + cSize.Y > viewSize.Y - 10 then
		targetY = aPos.Y - cSize.Y - 4
	end

	content.Position = UDim2.fromOffset(math.max(10, targetX), math.max(10, targetY))
end

function Popover.Close()
	if activeContent then
		activeContent.Visible = false
		activeContent.Parent = nil
		activeContent = nil
		activeAnchor = nil
		if closeCallback then
			local cb = closeCallback
			closeCallback = nil
			task.spawn(cb)
		end
	end
end

function Popover.Clean()
	Popover.Close()
	if inputConnection then
		inputConnection:Disconnect()
		inputConnection = nil
	end
	if popoverLayer then
		popoverLayer:Destroy()
		popoverLayer = nil
	end
end

return Popover
end

_modules['Components.Watermark'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Drag = _require("Core.Drag")

local Watermark = {}

function Watermark.New(gui, defaultText)
	local frame = Elements.Create("Frame", {
		Name = "VynxWatermark",
		Size = UDim2.new(0, 0, 0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = Theme.Get("Secondary"),
		ZIndex = 90,
		Parent = gui,
	})
	Elements.Round(frame, 6)
	local stroke = Elements.Stroke(frame, Theme.Get("Border"), 1, 0)
	Theme.Register(frame, "BackgroundColor3", "Secondary")
	Theme.Register(stroke, "Color", "Border")
	Elements.Padding(frame, { Top = 4, Bottom = 4, Left = 10, Right = 10 })

	local dot = Elements.Create("Frame", {
		Size = UDim2.new(0, 6, 0, 6),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Theme.Get("Accent"),
		ZIndex = 91,
		Parent = frame,
	})
	Elements.Round(dot, 3)
	Theme.Register(dot, "BackgroundColor3", "Accent")

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = defaultText or "vynx",
		TextColor3 = Theme.Get("Text"),
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		ZIndex = 91,
		Parent = frame,
	})
	Theme.Register(label, "TextColor3", "Text")

	Drag.Make(frame, frame, 0.2)

	local watermarkObj = {
		Frame = frame,
		SetText = function(self, text)
			label.Text = text
		end,
		SetVisible = function(self, visible)
			frame.Visible = visible
		end,
	}

	return watermarkObj
end

return Watermark
end

_modules['Components.Button'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Tooltip = _require("Core.Tooltip")

local Button = {}

function Button.New(parent, options)
	local callback = options.Func or options.Callback or function() end
	local originalText = options.Text or "Button"
	local waitingConfirm = false
	local confirmThread = nil

	local btn = Elements.Create("TextButton", {
		Name = originalText .. "_Btn",
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = originalText,
		TextColor3 = Theme.Get("Text"),
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		ClipsDescendants = true,
		Parent = parent,
	})

	Elements.Round(btn, 6)
	local stroke = Elements.Stroke(btn, Theme.Get("Border"), 1, 0)
	Theme.Register(btn, "BackgroundColor3", "Surface")
	Theme.Register(btn, "TextColor3", "Text")
	Theme.Register(stroke, "Color", "Border")

	if options.Tooltip then
		Tooltip.Attach(btn, options.Tooltip)
	end

	local uiScale = Elements.Scale(btn, 1)

	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	btn.MouseEnter:Connect(function()
		Elements.Tween(stroke, tweenInfo, { Color = Theme.Get("Accent") })
	end)

	btn.MouseLeave:Connect(function()
		Elements.Tween(stroke, tweenInfo, { Color = Theme.Get("Border") })
	end)

	btn.MouseButton1Click:Connect(function()
		Elements.Tween(uiScale, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 0.96,
		})
		task.delay(0.06, function()
			Elements.Tween(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1.0,
			})
		end)

		if options.DoubleClick then
			if waitingConfirm then
				waitingConfirm = false
				if confirmThread then
					task.cancel(confirmThread)
					confirmThread = nil
				end
				btn.Text = originalText
				task.spawn(callback)
			else
				waitingConfirm = true
				btn.Text = "Click again to confirm"
				confirmThread = task.delay(2.5, function()
					waitingConfirm = false
					btn.Text = originalText
				end)
			end
		else
			task.spawn(callback)
		end
	end)

	return btn
end

return Button
end

_modules['Components.Colorpicker'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Tooltip = _require("Core.Tooltip")
local Popover = _require("Components.Popover")

local Colorpicker = {}

local function toHex(c)
	return string.format("#%02X%02X%02X", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end

local function fromHex(hex)
	local clean = string.gsub(hex, "[#%s]", "")
	if #clean == 6 then
		local r = tonumber(string.sub(clean, 1, 2), 16)
		local g = tonumber(string.sub(clean, 3, 4), 16)
		local b = tonumber(string.sub(clean, 5, 6), 16)
		if r and g and b then
			return Color3.fromRGB(r, g, b)
		end
	end
	return nil
end

function Colorpicker.New(parent, id, options, registry, isEmbedded)
	local currentColor = options.Default or Color3.fromRGB(138, 75, 255)
	local currentAlpha = options.Transparency or 0
	local callback = options.Callback or function() end
	local isOpen = false

	local frame = Elements.Create("Frame", {
		Name = id .. "_Colorpicker",
		Size = isEmbedded and UDim2.new(0, 32, 0, 18) or UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = parent,
	})

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	if not isEmbedded and (options.Text and options.Text ~= "") then
		local label = Elements.Create("TextLabel", {
			Size = UDim2.new(1, -40, 1, 0),
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

	local previewBtn = Elements.Create("TextButton", {
		Size = isEmbedded and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 32, 0, 18),
		AnchorPoint = isEmbedded and Vector2.zero or Vector2.new(1, 0.5),
		Position = isEmbedded and UDim2.new(0, 0, 0, 0) or UDim2.new(1, -2, 0.5, 0),
		BackgroundColor3 = currentColor,
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
	Elements.Round(previewBtn, 4)
	local previewStroke = Elements.Stroke(previewBtn, Theme.Get("Border"), 1, 0)
	Theme.Register(previewStroke, "Color", "Border")

	local popover = Elements.Create("Frame", {
		Name = id .. "_PopoverPalette",
		Size = UDim2.new(0, 180, 0, 140),
		BackgroundColor3 = Theme.Get("Secondary"),
		Visible = false,
	})
	Elements.Round(popover, 6)
	local popoverStroke = Elements.Stroke(popover, Theme.Get("Border"), 1, 0)
	Theme.Register(popover, "BackgroundColor3", "Secondary")
	Theme.Register(popoverStroke, "Color", "Border")
	Elements.Padding(popover, 8)

	local popoverLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = popover,
	})

	local hexBox = Elements.Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = toHex(currentColor),
		TextColor3 = Theme.Get("Text"),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
		LayoutOrder = 1,
		Parent = popover,
	})
	Elements.Round(hexBox, 4)
	Theme.Register(hexBox, "BackgroundColor3", "Surface")
	Theme.Register(hexBox, "TextColor3", "Text")

	local swatchGridFrame = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = popover,
	})

	local swatchLayout = Elements.Create("UIGridLayout", {
		CellSize = UDim2.new(0, 36, 0, 24),
		CellPadding = UDim2.new(0, 5, 0, 5),
		Parent = swatchGridFrame,
	})

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

	local colorpickerObj = {
		Frame = frame,
		Value = currentColor,
		Transparency = currentAlpha,
		Callback = callback,
		SetValue = function(self, newCol, newAlpha)
			self.Value = newCol
			if newAlpha ~= nil then
				self.Transparency = newAlpha
			end
			previewBtn.BackgroundColor3 = newCol
			hexBox.Text = toHex(newCol)
			task.spawn(self.Callback, newCol, self.Transparency)
		end,
	}

	for _, col in ipairs(swatches) do
		local sBtn = Elements.Create("TextButton", {
			BackgroundColor3 = col,
			Text = "",
			AutoButtonColor = false,
			Parent = swatchGridFrame,
		})
		Elements.Round(sBtn, 4)
		Elements.Stroke(sBtn, Color3.fromRGB(30, 30, 40), 1, 0)

		sBtn.MouseButton1Click:Connect(function()
			colorpickerObj:SetValue(col)
		end)
	end

	hexBox.FocusLost:Connect(function()
		local parsed = fromHex(hexBox.Text)
		if parsed then
			colorpickerObj:SetValue(parsed)
		else
			hexBox.Text = toHex(colorpickerObj.Value)
		end
	end)

	previewBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			hexBox.Text = toHex(colorpickerObj.Value)
			Popover.Open(popover, previewBtn, function()
				isOpen = false
			end)
		else
			Popover.Close()
		end
	end)

	frame.Destroying:Connect(function()
		popover:Destroy()
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
local Tooltip = _require("Core.Tooltip")

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
end

_modules['Components.Toggle'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Tooltip = _require("Core.Tooltip")
local Colorpicker = _require("Components.Colorpicker")
local Keybind = _require("Components.Keybind")

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
end

_modules['Components.Slider'] = function()
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Tooltip = _require("Core.Tooltip")

local Slider = {}

local function round(val, decimals)
	local factor = 10 ^ (decimals or 0)
	return math.round(val * factor) / factor
end

function Slider.New(parent, id, options, registry)
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
	})

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
	})
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
	})
	Theme.Register(valLabel, "TextColor3", "SubText")

	local track = Elements.Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 0, 24),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
	Elements.Round(track, 5)
	local trackStroke = Elements.Stroke(track, Theme.Get("Border"), 1, 0)
	Theme.Register(track, "BackgroundColor3", "Surface")
	Theme.Register(trackStroke, "Color", "Border")

	local percent = (currentVal - minVal) / (maxVal - minVal)

	local fill = Elements.Create("Frame", {
		Size = UDim2.new(percent, 0, 1, 0),
		BackgroundColor3 = Theme.Get("Accent"),
		Parent = track,
	})
	Elements.Round(fill, 5)
	Theme.Register(fill, "BackgroundColor3", "Accent")

	local sliderObj = {
		Value = currentVal,
		Callback = callback,
		SetValue = function(self, newVal)
			local clamped = math.clamp(round(newVal, roundingDecimals), minVal, maxVal)
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
	local parentScroll = nil
	local originalScrollState = true

	local function updateFromInput(inputPos)
		local absPos = track.AbsolutePosition
		local absSize = track.AbsoluteSize
		local relativeX = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
		local val = minVal + (maxVal - minVal) * relativeX
		sliderObj:SetValue(val)
	end

	local c1 = track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			parentScroll = track:FindFirstAncestorOfClass("ScrollingFrame")
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

	registry[id] = sliderObj
	return sliderObj
end

return Slider
end

_modules['Components.Input'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Tooltip = _require("Core.Tooltip")

local Input = {}

function Input.New(parent, id, options, registry)
	local currentText = options.Default or ""
	local callback = options.Callback or function() end
	local isFinishedMode = true
	if options.Finished ~= nil then
		isFinishedMode = options.Finished
	end

	local frame = Elements.Create("Frame", {
		Name = id .. "_Input",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		Parent = parent,
	})

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
	})
	Theme.Register(label, "TextColor3", "Text")

	local inputBg = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundColor3 = Theme.Get("Surface"),
		Parent = frame,
	})
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
	})
	Theme.Register(textBox, "TextColor3", "Text")
	Theme.Register(textBox, "PlaceholderColor3", "SubText")

	local inputObj = {
		Value = currentText,
		Callback = callback,
		SetValue = function(self, newText)
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
		textBox.FocusLost:Connect(function(enterPressed)
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
end

_modules['Components.Dropdown'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Tooltip = _require("Core.Tooltip")
local Popover = _require("Components.Popover")

local Dropdown = {}

function Dropdown.New(parent, id, options, registry)
	local values = options.Values or {}
	local isMulti = options.Multi or false
	local callback = options.Callback or function() end
	local isOpen = false

	local currentValue
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
		Parent = parent,
	})

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
	})
	Theme.Register(label, "TextColor3", "Text")

	local box = Elements.Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundColor3 = Theme.Get("Surface"),
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
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
		Parent = box,
	})
	Theme.Register(valLabel, "TextColor3", "Text")

	local arrow = Elements.Create("TextLabel", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -22, 0, 0),
		BackgroundTransparency = 1,
		Text = "v",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		Parent = box,
	})
	Theme.Register(arrow, "TextColor3", "SubText")

	local listFrame = Elements.Create("Frame", {
		Name = id .. "_PopoverList",
		Size = UDim2.new(0, 240, 0, 160),
		BackgroundColor3 = Theme.Get("Secondary"),
		Visible = false,
	})
	Elements.Round(listFrame, 6)
	local listStroke = Elements.Stroke(listFrame, Theme.Get("Border"), 1, 0)
	Theme.Register(listFrame, "BackgroundColor3", "Secondary")
	Theme.Register(listStroke, "Color", "Border")
	Elements.Padding(listFrame, 6)

	local listLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = listFrame,
	})

	local searchBox = Elements.Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Theme.Get("Surface"),
		PlaceholderText = "Search...",
		PlaceholderColor3 = Theme.Get("SubText"),
		TextColor3 = Theme.Get("Text"),
		Text = "",
		TextSize = 12,
		Font = Enum.Font.Gotham,
		Visible = #values > 5,
		LayoutOrder = 1,
		Parent = listFrame,
	})
	Elements.Round(searchBox, 4)
	Theme.Register(searchBox, "BackgroundColor3", "Surface")
	Theme.Register(searchBox, "TextColor3", "Text")

	local scrollContainer = Elements.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, #values > 5 and -28 or 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Get("Accent"),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = listFrame,
	})

	local itemsLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = scrollContainer,
	})

	local function getDisplayText()
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
		SetValue = function(self, newVal)
			self.Value = newVal
			currentValue = newVal
			valLabel.Text = getDisplayText()
			task.spawn(self.Callback, newVal)
		end,
		SetValues = function(self, newValues)
			self.Values = newValues
		end,
	}

	local function refreshItems(filter)
		for _, child in ipairs(scrollContainer:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local query = filter and string.lower(filter) or ""
		for _, itemVal in ipairs(dropdownObj.Values) do
			if query == "" or string.find(string.lower(itemVal), query, 1, true) then
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
					Parent = scrollContainer,
				})
				Elements.Round(itemBtn, 4)

				itemBtn.MouseButton1Click:Connect(function()
					if isMulti then
						currentValue[itemVal] = not currentValue[itemVal]
						dropdownObj:SetValue(currentValue)
						refreshItems(searchBox.Text)
					else
						dropdownObj:SetValue(itemVal)
						isOpen = false
						arrow.Text = "v"
						Popover.Close()
					end
				end)
			end
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		refreshItems(searchBox.Text)
	end)

	local themeConn = Theme.Changed:Connect(function(palette)
		valLabel.TextColor3 = palette.Text
		if isOpen then
			refreshItems(searchBox.Text)
		end
	end)

	box.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		arrow.Text = isOpen and "^" or "v"
		if isOpen then
			listFrame.Size = UDim2.new(0, math.max(box.AbsoluteSize.X, 180), 0, math.min(#dropdownObj.Values * 26 + 40, 160))
			refreshItems("")
			Popover.Open(listFrame, box, function()
				isOpen = false
				arrow.Text = "v"
			end)
		else
			Popover.Close()
		end
	end)

	frame.Destroying:Connect(function()
		themeConn:Disconnect()
		listFrame:Destroy()
	end)

	registry[id] = dropdownObj
	return dropdownObj
end

return Dropdown
end

_modules['Components.Notification'] = function()
local TweenService = game:GetService("TweenService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local Notification = {}

local holder = nil
local activeQueue = {}
local MAX_NOTIFICATIONS = 5

function Notification.Init(gui)
	if holder and holder.Parent then return end

	holder = Elements.Create("Frame", {
		Name = "VynxNotificationHolder",
		Size = UDim2.new(0, 280, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -10),
		BackgroundTransparency = 1,
		ZIndex = 800,
		Parent = gui,
	})

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 8),
		Parent = holder,
	})
end

function Notification.Show(info)
	if not holder then return end

	if #activeQueue >= MAX_NOTIFICATIONS then
		local oldest = table.remove(activeQueue, 1)
		if oldest and oldest.Parent then
			oldest:Destroy()
		end
	end

	local duration = info.Duration or 3.5
	local nType = info.Type or "Info"

	local typeColors = {
		Info = Theme.Get("Accent"),
		Success = Color3.fromRGB(46, 213, 115),
		Warn = Color3.fromRGB(255, 171, 0),
		Error = Color3.fromRGB(255, 75, 75),
	}
	local typeColor = typeColors[nType] or Theme.Get("Accent")

	local wrapper = Elements.Create("Frame", {
		Name = "ToastWrapper",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent = holder,
	})
	table.insert(activeQueue, wrapper)

	local toast = Elements.Create("Frame", {
		Name = "Toast",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Get("Secondary"),
		Position = UDim2.new(1, 300, 0, 0),
		ZIndex = 801,
		Parent = wrapper,
	})
	Elements.Round(toast, 6)
	local stroke = Elements.Stroke(toast, Theme.Get("Border"), 1, 0)
	Theme.Register(toast, "BackgroundColor3", "Secondary")
	Theme.Register(stroke, "Color", "Border")
	Elements.Padding(toast, { Top = 8, Bottom = 10, Left = 12, Right = 12 })

	local contentLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = toast,
	})

	local titleLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = info.Title or nType,
		TextColor3 = typeColor,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		ZIndex = 802,
		Parent = toast,
	})

	local contentLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = info.Content,
		TextColor3 = Theme.Get("Text"),
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		LayoutOrder = 2,
		ZIndex = 802,
		Parent = toast,
	})
	Theme.Register(contentLabel, "TextColor3", "Text")

	local barBg = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Theme.Get("Surface"),
		LayoutOrder = 3,
		ZIndex = 802,
		Parent = toast,
	})

	local progress = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = typeColor,
		ZIndex = 803,
		Parent = barBg,
	})

	Elements.Tween(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
	})

	local isPaused = false
	local timeLeft = duration

	toast.MouseEnter:Connect(function()
		isPaused = true
	end)

	toast.MouseLeave:Connect(function()
		isPaused = false
	end)

	task.spawn(function()
		while timeLeft > 0 and wrapper.Parent do
			local dt = task.wait(0.05)
			if not isPaused then
				timeLeft = timeLeft - dt
				progress.Size = UDim2.new(math.clamp(timeLeft / duration, 0, 1), 0, 1, 0)
			end
		end

		if wrapper.Parent then
			local outTween = Elements.Tween(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(1, 300, 0, 0),
			})
			outTween.Completed:Connect(function()
				local idx = table.find(activeQueue, wrapper)
				if idx then
					table.remove(activeQueue, idx)
				end
				wrapper:Destroy()
			end)
		end
	end)
end

function Notification.Clean()
	table.clear(activeQueue)
	if holder then
		holder:Destroy()
		holder = nil
	end
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

function Groupbox.New(parent, title, library)
	local isCollapsed = false

	local box = Elements.Create("Frame", {
		Name = title .. "_Groupbox",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Get("Secondary"),
		ZIndex = 2,
		Parent = parent,
	})
	Elements.Round(box, 6)
	local boxStroke = Elements.Stroke(box, Theme.Get("Border"), 1, 0)
	Theme.Register(box, "BackgroundColor3", "Secondary")
	Theme.Register(boxStroke, "Color", "Border")
	Elements.Padding(box, { Top = 10, Bottom = 10, Left = 12, Right = 12 })

	local boxLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = box,
	})

	local headerRow = Elements.Create("Frame", {
		Name = "HeaderRow",
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		ZIndex = 3,
		Parent = box,
	})

	local header = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -24, 1, 0),
		BackgroundTransparency = 1,
		Text = string.upper(title),
		TextColor3 = Theme.Get("Accent"),
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = headerRow,
	})
	Theme.Register(header, "TextColor3", "Accent")

	local collapseBtn = Elements.Create("TextButton", {
		Size = UDim2.new(0, 16, 0, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Text = "-",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		ZIndex = 3,
		Parent = headerRow,
	})
	Theme.Register(collapseBtn, "TextColor3", "SubText")

	local container = Elements.Create("Frame", {
		Name = "Container",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		ZIndex = 3,
		Parent = box,
	})

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = container,
	})

	collapseBtn.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed
		collapseBtn.Text = isCollapsed and "+" or "-"
		container.Visible = not isCollapsed
	end)

	local boxObj = {
		Frame = box,
		Container = container,
		AddToggle = function(self, id, options)
			return Toggle.New(container, id, options, library)
		end,
		AddButton = function(self, options)
			return Button.New(container, options)
		end,
		AddSlider = function(self, id, options)
			return Slider.New(container, id, options, library.Options)
		end,
		AddDropdown = function(self, id, options)
			return Dropdown.New(container, id, options, library.Options)
		end,
		AddColorpicker = function(self, id, options)
			return Colorpicker.New(container, id, options, library.Options)
		end,
		AddKeybind = function(self, id, options)
			return Keybind.New(container, id, options, library.Options)
		end,
		AddInput = function(self, id, options)
			return Input.New(container, id, options, library.Options)
		end,
		AddDivider = function(self)
			local div = Elements.Create("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Get("Border"),
				BorderSizePixel = 0,
				Parent = container,
			})
			Theme.Register(div, "BackgroundColor3", "Border")
			return div
		end,
		AddLabel = function(self, text)
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
		AddDependencyBox = function(self, parentToggle)
			local depContainer = Elements.Create("Frame", {
				Name = "DependencyBox",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Visible = parentToggle.Value == true,
				Parent = container,
			})
			Elements.Padding(depContainer, { Top = 0, Bottom = 0, Left = 12, Right = 0 })

			local depLayout = Elements.Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
				Parent = depContainer,
			})

			local bar = Elements.Create("Frame", {
				Size = UDim2.new(0, 2, 1, 0),
				Position = UDim2.new(0, -6, 0, 0),
				BackgroundColor3 = Theme.Get("Accent"),
				BorderSizePixel = 0,
				Parent = depContainer,
			})
			Theme.Register(bar, "BackgroundColor3", "Accent")

			local oldCb = parentToggle.Callback
			parentToggle.Callback = function(val)
				depContainer.Visible = val
				if oldCb then oldCb(val) end
			end

			local depObj = Groupbox.New(depContainer, "", library)
			depObj.Frame.BackgroundTransparency = 1
			depObj.Frame.BorderSizePixel = 0
			return depObj
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

function Tab.New(parent, name, library)
	local page = Elements.Create("Frame", {
		Name = name .. "_Page",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

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
	})

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
	})

	local rightLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = rightColumn,
	})

	local tabObj = {
		Name = name,
		Page = page,
		AddLeftGroupbox = function(self, title)
			return Groupbox.New(leftColumn, title, library)
		end,
		AddRightGroupbox = function(self, title)
			return Groupbox.New(rightColumn, title, library)
		end,
		Show = function(self)
			page.Visible = true
		end,
		Hide = function(self)
			page.Visible = false
		end,
	}

	return tabObj
end

return Tab
end

_modules['Components.Window'] = function()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Drag = _require("Core.Drag")
local Tab = _require("Components.Tab")

local Window = {}

function Window.New(gui, options, library)
	local windowSize = options.Size or UDim2.fromOffset(620, 440)
	local tabWidth = options.TabWidth or 130
	local toggleKey = options.Keybind or Enum.KeyCode.RightControl
	local isVisible = true
	local maid = library.Maid

	local main = Elements.Create("Frame", {
		Name = "MainWindow",
		Size = windowSize,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Theme.Get("Background"),
		ClipsDescendants = false,
		Parent = gui,
	})
	Elements.Round(main, 8)

	local mainStroke = Elements.Stroke(main, Theme.Get("Border"), 1, 0)
	Theme.Register(main, "BackgroundColor3", "Background")
	Theme.Register(mainStroke, "Color", "Border")

	local strokeGradient = Elements.Gradient(mainStroke, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 150)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 50)),
	}), 90)

	local mainScale = Elements.Scale(main, 1)

	local topbar = Elements.Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		Parent = main,
	})

	Drag.Make(main, topbar, 0.25, maid)

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
	})
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
		})
		Theme.Register(subLabel, "TextColor3", "SubText")
		titleLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			subLabel.Position = UDim2.new(0, 14 + titleLabel.AbsoluteSize.X + 4, 0, 0)
		end)
	end

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
	})

	local topDivider = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 38),
		BackgroundColor3 = Theme.Get("Border"),
		BorderSizePixel = 0,
		Parent = main,
	})
	Theme.Register(topDivider, "BackgroundColor3", "Border")

	local sidebar = Elements.Create("ScrollingFrame", {
		Name = "Sidebar",
		Size = UDim2.new(0, tabWidth, 1, -64),
		Position = UDim2.new(0, 0, 0, 39),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = main,
	})
	Elements.Padding(sidebar, { Top = 10, Bottom = 10, Left = 8, Right = 8 })

	local tabListLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = sidebar,
	})

	local sideDivider = Elements.Create("Frame", {
		Size = UDim2.new(0, 1, 1, -64),
		Position = UDim2.new(0, tabWidth, 0, 39),
		BackgroundColor3 = Theme.Get("Border"),
		BorderSizePixel = 0,
		Parent = main,
	})
	Theme.Register(sideDivider, "BackgroundColor3", "Border")

	local pagesHolder = Elements.Create("Frame", {
		Name = "PagesHolder",
		Size = UDim2.new(1, -tabWidth - 1, 1, -64),
		Position = UDim2.new(0, tabWidth + 1, 0, 39),
		BackgroundTransparency = 1,
		Parent = main,
	})
	Elements.Padding(pagesHolder, 12)

	local statusBar = Elements.Create("Frame", {
		Name = "StatusBar",
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24),
		BackgroundColor3 = Theme.Get("Secondary"),
		BorderSizePixel = 0,
		Parent = main,
	})
	Elements.Round(statusBar, 4)
	Theme.Register(statusBar, "BackgroundColor3", "Secondary")
	Elements.Padding(statusBar, { Top = 0, Bottom = 0, Left = 12, Right = 12 })

	local statusLeft = Elements.Create("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "vynx  •  ready",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = statusBar,
	})
	Theme.Register(statusLeft, "TextColor3", "SubText")

	local statusRight = Elements.Create("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "60 fps • 0 ms",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = statusBar,
	})
	Theme.Register(statusRight, "TextColor3", "SubText")

	local frameCount = 0
	local lastTime = os.clock()
	local fpsConn = RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		local now = os.clock()
		if now - lastTime >= 1 then
			local fps = math.round(frameCount / (now - lastTime))
			statusRight.Text = string.format("%d fps", fps)
			frameCount = 0
			lastTime = now
		end
	end)
	maid:Give(fpsConn)

	local launcher = Elements.Create("TextButton", {
		Name = "VynxMobileLauncher",
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(0, 16, 0.5, -18),
		BackgroundColor3 = Theme.Get("Secondary"),
		Text = "V",
		TextColor3 = Theme.Get("Accent"),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 900,
		Parent = gui,
	})
	Elements.Round(launcher, 18)
	local launcherStroke = Elements.Stroke(launcher, Theme.Get("Accent"), 1.5, 0)
	Theme.Register(launcher, "BackgroundColor3", "Secondary")
	Theme.Register(launcher, "TextColor3", "Accent")
	Theme.Register(launcherStroke, "Color", "Accent")
	Drag.Make(launcher, launcher, 0.2, maid)

	local tabs = {}
	local currentTab = nil

	local windowObj = {
		Main = main,
		Launcher = launcher,
		AddTab = function(self, name)
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
			})
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

			local themeConn = Theme.Changed:Connect(function(palette)
				if currentTab == newTab then
					tabBtn.TextColor3 = palette.Accent
				end
			end)
			maid:Give(themeConn)

			tabBtn.MouseButton1Click:Connect(selectTab)
			table.insert(tabs, { Name = name, TabObj = newTab, Btn = tabBtn })

			if #tabs == 1 then
				selectTab()
			end

			return newTab
		end,
		Toggle = function(self, visible)
			if visible ~= nil then
				isVisible = visible
			else
				isVisible = not isVisible
			end

			if isVisible then
				main.Visible = true
				Elements.Tween(mainScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = 1.0,
				})
			else
				local outTween = Elements.Tween(mainScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Scale = 0.95,
				})
				outTween.Completed:Connect(function()
					if not isVisible then
						main.Visible = false
					end
				end)
			end
		end,
	}

	minBtn.MouseButton1Click:Connect(function()
		windowObj:Toggle(false)
	end)

	launcher.MouseButton1Click:Connect(function()
		windowObj:Toggle()
	end)

	local keyConn = UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			windowObj:Toggle()
		end
	end)
	maid:Give(keyConn)

	return windowObj
end

return Window
end

_modules['Main'] = function()
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Maid = _require("Core.Maid")
local Tooltip = _require("Core.Tooltip")
local SaveManager = _require("Core.SaveManager")
local Popover = _require("Components.Popover")
local Window = _require("Components.Window")
local Notification = _require("Components.Notification")
local Watermark = _require("Components.Watermark")

local Library = {
	Toggles = {},
	Options = {},
	Theme = Theme,
	SaveManager = SaveManager,
	ScreenGui = nil,
	ActiveWindow = nil,
	ActiveWatermark = nil,
	UnloadSignals = {},
	Maid = Maid.new(),
}

SaveManager:SetLibrary(Library)

local function getGuiParent()
	if typeof(gethui) == "function" then
		local ok, h = pcall(gethui)
		if ok and h then return h end
	end

	local okCore = pcall(function()
		local test = Instance.new("Folder")
		test.Parent = CoreGui
		test:Destroy()
	end)
	if okCore then
		return CoreGui
	end

	local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		return playerGui
	end

	return CoreGui
end

function Library:InitGui()
	if self.ScreenGui and self.ScreenGui.Parent then
		return self.ScreenGui
	end

	local gui = Elements.Create("ScreenGui", {
		Name = "vynx_" .. string.sub(tostring(math.random()), 3, 8),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		Parent = getGuiParent(),
	})

	if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
		pcall(function() syn.protect_gui(gui) end)
	end

	self.ScreenGui = gui
	Popover.Init(gui, self.Maid)
	Notification.Init(gui)
	Tooltip.Init(gui)
	return gui
end

function Library:CreateWindow(options)
	local gui = self:InitGui()
	local win = Window.New(gui, options, self)
	self.ActiveWindow = win
	return win
end

function Library:Notify(info)
	if not self.ScreenGui then
		self:InitGui()
	end
	Notification.Show(info)
end

function Library:SetWatermark(text)
	local gui = self:InitGui()
	if not self.ActiveWatermark then
		self.ActiveWatermark = Watermark.New(gui, text)
	else
		self.ActiveWatermark:SetText(text)
	end
	return self.ActiveWatermark
end

function Library:SetWatermarkVisibility(visible)
	if self.ActiveWatermark then
		self.ActiveWatermark:SetVisible(visible)
	end
end

function Library:SetTheme(nameOrPalette)
	Theme.SetTheme(nameOrPalette)
end

function Library:OnUnload(callback)
	table.insert(self.UnloadSignals, callback)
end

function Library:Unload()
	for _, cb in ipairs(self.UnloadSignals) do
		task.spawn(cb)
	end
	table.clear(self.UnloadSignals)

	self.Maid:Clean()
	Popover.Clean()
	Tooltip.Clean()
	Notification.Clean()

	if self.ScreenGui then
		self.ScreenGui:Destroy()
		self.ScreenGui = nil
	end

	table.clear(self.Toggles)
	table.clear(self.Options)
	self.ActiveWatermark = nil
	self.ActiveWindow = nil
end

return Library
end

return _require('Main')