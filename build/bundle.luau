--[[
    Vynx UI Library - Standalone Single File Bundle (macOS Sequoia Edition)
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

_modules['Core.Motion'] = function()
local TweenService = game:GetService("TweenService")

local Motion = {
	Fast = 0.12,
	Base = 0.20,
	Slow = 0.35,
	DefaultEasing = Enum.EasingStyle.Quad,
	DefaultDirection = Enum.EasingDirection.Out,
	QuintEasing = Enum.EasingStyle.Quint,
}

function Motion.Tween(instance, duration, goal, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(
		duration or Motion.Base,
		easingStyle or Motion.DefaultEasing,
		easingDirection or Motion.DefaultDirection
	)
	local tween = TweenService:Create(instance, tweenInfo, goal)
	tween:Play()
	return tween
end

function Motion.SpringTween(instance, duration, goal)
	local tweenInfo = TweenInfo.new(
		duration or Motion.Base,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, tweenInfo, goal)
	tween:Play()
	return tween
end

return Motion
end

_modules['Core.Theme'] = function()
local TweenService = game:GetService("TweenService")

local Theme = {}

-- Accent Palettes (Human Interface Guidelines values)
Theme.Accents = {
	Blue = Color3.fromRGB(10, 132, 255),       -- #0A84FF (Default)
	Purple = Color3.fromRGB(191, 90, 242),     -- #BF5AF2
	Pink = Color3.fromRGB(255, 55, 95),        -- #FF375F
	Red = Color3.fromRGB(255, 69, 58),         -- #FF453A
	Orange = Color3.fromRGB(255, 159, 10),     -- #FF9F0A
	Yellow = Color3.fromRGB(255, 214, 10),     -- #FFD60A
	Green = Color3.fromRGB(48, 209, 88),       -- #30D158
	Graphite = Color3.fromRGB(152, 152, 159),  -- #98989F
}

-- Base Themes
Theme.Themes = {
	Dark = {
		Window = Color3.fromRGB(28, 28, 30),         -- #1C1C1E
		Sidebar = Color3.fromRGB(35, 35, 38),        -- #232326
		FormCard = Color3.fromRGB(44, 44, 46),       -- #2C2C2E
		ControlFill = Color3.fromRGB(58, 58, 60),    -- #3A3A3C
		ControlTrack = Color3.fromRGB(72, 72, 74),   -- #48484A
		Hairline = Color3.fromRGB(255, 255, 255),
		HairlineTransparency = 0.92,
		WindowStroke = Color3.fromRGB(255, 255, 255),
		WindowStrokeTransparency = 0.90,
		Text = Color3.fromRGB(255, 255, 255),
		SecondaryText = Color3.fromRGB(152, 152, 159), -- #98989F
		TertiaryText = Color3.fromRGB(99, 99, 102),    -- #636366
		Overlay = Color3.fromRGB(0, 0, 0),
		OverlayTransparency = 0.40,
		HoverTint = Color3.fromRGB(255, 255, 255),
		HoverTransparency = 0.94,
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Light = {
		Window = Color3.fromRGB(242, 242, 247),       -- #F2F2F7
		Sidebar = Color3.fromRGB(229, 229, 234),      -- #E5E5EA
		FormCard = Color3.fromRGB(255, 255, 255),     -- #FFFFFF
		ControlFill = Color3.fromRGB(229, 229, 234),  -- #E5E5EA
		ControlTrack = Color3.fromRGB(209, 209, 214), -- #D1D1D6
		Hairline = Color3.fromRGB(0, 0, 0),
		HairlineTransparency = 0.92,
		WindowStroke = Color3.fromRGB(0, 0, 0),
		WindowStrokeTransparency = 0.88,
		Text = Color3.fromRGB(28, 28, 30),            -- #1C1C1E
		SecondaryText = Color3.fromRGB(110, 110, 115),-- #6E6E73
		TertiaryText = Color3.fromRGB(174, 174, 178), -- #AEAEB2
		Overlay = Color3.fromRGB(0, 0, 0),
		OverlayTransparency = 0.25,
		HoverTint = Color3.fromRGB(0, 0, 0),
		HoverTransparency = 0.95,
		Shadow = Color3.fromRGB(100, 100, 110),
	},
}

-- Semantic status tokens
Theme.Semantics = {
	Success = Color3.fromRGB(48, 209, 88),
	Warning = Color3.fromRGB(255, 159, 10),
	Danger = Color3.fromRGB(255, 69, 58),
}

-- Typography setup (Roblox px)
Theme.Typography = {
	PageTitle = { Size = 22, Font = Enum.Font.GothamBold },
	SectionHeading = { Size = 13, Font = Enum.Font.GothamBold },
	RowTitle = { Size = 14, Font = Enum.Font.GothamMedium },
	Subtitle = { Size = 12, Font = Enum.Font.Gotham },
	Caption = { Size = 11, Font = Enum.Font.Gotham },
	Code = { Size = 12, Font = Enum.Font.Code },
}

Theme.CurrentThemeName = "Dark"
Theme.CurrentAccentName = "Blue"
Theme.CurrentTheme = Theme.Themes.Dark
Theme.CurrentAccent = Theme.Accents.Blue

Theme.ChangedEvent = Instance.new("BindableEvent")
Theme.Changed = Theme.ChangedEvent.Event

-- Multi-property weak registry: instance -> { [PropertyName]: TokenName }
Theme.Registry = setmetatable({}, { __mode = "k" })

-- Backward compatibility aliases mapping legacy tokens to Sequoia tokens
local TokenAliases = {
	Accent = function() return Theme.CurrentAccent end,
	Background = function() return Theme.CurrentTheme.Window end,
	Secondary = function() return Theme.CurrentTheme.Sidebar end,
	Surface = function() return Theme.CurrentTheme.FormCard end,
	Border = function() return Theme.CurrentTheme.WindowStroke end,
	Text = function() return Theme.CurrentTheme.Text end,
	SubText = function() return Theme.CurrentTheme.SecondaryText end,
	ControlFill = function() return Theme.CurrentTheme.ControlFill end,
	ControlTrack = function() return Theme.CurrentTheme.ControlTrack end,
	Window = function() return Theme.CurrentTheme.Window end,
	Sidebar = function() return Theme.CurrentTheme.Sidebar end,
	FormCard = function() return Theme.CurrentTheme.FormCard end,
	Hairline = function() return Theme.CurrentTheme.Hairline end,
	WindowStroke = function() return Theme.CurrentTheme.WindowStroke end,
	SecondaryText = function() return Theme.CurrentTheme.SecondaryText end,
	TertiaryText = function() return Theme.CurrentTheme.TertiaryText end,
	Success = function() return Theme.Semantics.Success end,
	Warning = function() return Theme.Semantics.Warning end,
	Danger = function() return Theme.Semantics.Danger end,
}

function Theme.Get(token)
	if token == "Accent" then
		return Theme.CurrentAccent
	elseif TokenAliases[token] then
		return TokenAliases[token]()
	elseif Theme.CurrentTheme[token] then
		return Theme.CurrentTheme[token]
	elseif Theme.Semantics[token] then
		return Theme.Semantics[token]
	end
	return Color3.fromRGB(255, 255, 255)
end

function Theme.Register(instance, property, token)
	if not Theme.Registry[instance] then
		Theme.Registry[instance] = {}
	end
	Theme.Registry[instance][property] = token

	local color = Theme.Get(token)
	if color then
		instance[property] = color
	end
	return instance
end

function Theme.ApplyUpdates(duration)
	local tweenInfo = TweenInfo.new(duration or 0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for instance, propMap in pairs(Theme.Registry) do
		if instance and instance.Parent then
			local goals = {}
			for prop, token in pairs(propMap) do
				local color = Theme.Get(token)
				if color then
					goals[prop] = color
				end
			end
			if next(goals) ~= nil then
				TweenService:Create(instance, tweenInfo, goals):Play()
			end
		end
	end
	Theme.ChangedEvent:Fire(Theme.CurrentTheme, Theme.CurrentAccent)
end

function Theme.SetTheme(themeName, duration)
	if Theme.Themes[themeName] then
		Theme.CurrentThemeName = themeName
		Theme.CurrentTheme = Theme.Themes[themeName]
	elseif themeName == "Obsidian" or themeName == "Cyberpunk" or themeName == "Emerald" or themeName == "Monochrome" then
		-- Legacy preset compatibility
		Theme.CurrentThemeName = "Dark"
		Theme.CurrentTheme = Theme.Themes.Dark
		if themeName == "Cyberpunk" then
			Theme.CurrentAccent = Theme.Accents.Blue
		elseif themeName == "Emerald" then
			Theme.CurrentAccent = Theme.Accents.Green
		elseif themeName == "Monochrome" then
			Theme.CurrentAccent = Theme.Accents.Graphite
		else
			Theme.CurrentAccent = Theme.Accents.Purple
		end
	end
	Theme.ApplyUpdates(duration)
end

function Theme.SetAccent(accentNameOrColor, duration)
	if typeof(accentNameOrColor) == "string" and Theme.Accents[accentNameOrColor] then
		Theme.CurrentAccentName = accentNameOrColor
		Theme.CurrentAccent = Theme.Accents[accentNameOrColor]
	elseif typeof(accentNameOrColor) == "Color3" then
		Theme.CurrentAccentName = "Custom"
		Theme.CurrentAccent = accentNameOrColor
	end
	Theme.ApplyUpdates(duration)
end

return Theme
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

function Elements.Shadow(target, radius, opacity)
	local shadowHolder = Instance.new("Frame")
	shadowHolder.Name = "ShadowHolder"
	shadowHolder.Size = UDim2.new(1, 16, 1, 16)
	shadowHolder.Position = UDim2.new(0, -8, 0, -4)
	shadowHolder.BackgroundTransparency = 1
	shadowHolder.ZIndex = math.max(1, (target.ZIndex or 2) - 1)
	shadowHolder.Parent = target.Parent

	-- 3-layer stacked soft shadow without external images
	for i = 1, 3 do
		local layer = Instance.new("Frame")
		layer.Name = "ShadowLayer" .. i
		layer.Size = UDim2.new(1, i * 4, 1, i * 4)
		layer.Position = UDim2.new(0.5, 0, 0.5, i * 2)
		layer.AnchorPoint = Vector2.new(0.5, 0.5)
		layer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		layer.BackgroundTransparency = (opacity or 0.7) + (i * 0.08)
		layer.BorderSizePixel = 0
		layer.ZIndex = shadowHolder.ZIndex
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, (radius or 12) + i * 2)
		corner.Parent = layer
		layer.Parent = shadowHolder
	end

	target:GetPropertyChangedSignal("Visible"):Connect(function()
		shadowHolder.Visible = target.Visible
	end)
	target:GetPropertyChangedSignal("Position"):Connect(function()
		shadowHolder.Position = UDim2.new(
			target.Position.X.Scale,
			target.Position.X.Offset - 8,
			target.Position.Y.Scale,
			target.Position.Y.Offset - 4
		)
	end)
	target:GetPropertyChangedSignal("Size"):Connect(function()
		shadowHolder.Size = UDim2.new(target.Size.X.Scale, target.Size.X.Offset + 16, target.Size.Y.Scale, target.Size.Y.Offset + 16)
	end)

	target.Destroying:Connect(function()
		shadowHolder:Destroy()
	end)

	return shadowHolder
end

function Elements.Hairline(target, insetLeft)
	local hairline = Instance.new("Frame")
	hairline.Name = "Hairline"
	hairline.Size = UDim2.new(1, -(insetLeft or 12), 0, 1)
	hairline.Position = UDim2.new(0, insetLeft or 12, 1, -1)
	hairline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hairline.BackgroundTransparency = 0.92
	hairline.BorderSizePixel = 0
	hairline.ZIndex = (target.ZIndex or 2) + 1
	hairline.Parent = target
	return hairline
end

function Elements.Tween(target, info, properties)
	local tween = TweenService:Create(target, info, properties)
	tween:Play()
	return tween
end

return Elements
end

_modules['Core.Icons'] = function()
local Elements = _require("Core.Elements")

local Icons = {}

-- Original SF-inspired glyph mappings using clean unicode symbols
Icons.Glyphs = {
	["gear"] = "⚙",
	["settings"] = "⚙",
	["sliders"] = "⚲",
	["combat"] = "⚔",
	["shield"] = "🛡",
	["eye"] = "◎",
	["visuals"] = "◎",
	["waveform"] = "〰",
	["audio"] = "♫",
	["keyboard"] = "⌨",
	["paint"] = "🎨",
	["palette"] = "🎨",
	["folder"] = "📁",
	["search"] = "⌕",
	["close"] = "✕",
	["minimize"] = "−",
	["maximize"] = "+",
	["chevron.right"] = "›",
	["chevron.down"] = "⌄",
	["checkmark"] = "✓",
	["circle"] = "●",
	["star"] = "★",
	["sparkles"] = "✦",
	["cursor"] = "➤",
	["bell"] = "🔔",
	["info"] = "ⓘ",
	["warn"] = "⚠",
	["error"] = "✕",
}

function Icons.Get(nameOrAsset)
	if not nameOrAsset or nameOrAsset == "" then
		return nil
	end
	if Icons.Glyphs[nameOrAsset] then
		return Icons.Glyphs[nameOrAsset]
	end
	return nameOrAsset
end

function Icons.Render(nameOrAsset, parent, size, color)
	local resolved = Icons.Get(nameOrAsset)
	if not resolved then
		return nil
	end

	local sz = size or 16
	if string.sub(resolved, 1, 13) == "rbxassetid://" or string.sub(resolved, 1, 9) == "http://" or string.sub(resolved, 1, 10) == "https://" then
		local img = Elements.Create("ImageLabel", {
			Size = UDim2.fromOffset(sz, sz),
			BackgroundTransparency = 1,
			Image = resolved,
			ImageColor3 = color or Color3.fromRGB(255, 255, 255),
			Parent = parent,
		})
		return img
	else
		local lbl = Elements.Create("TextLabel", {
			Size = UDim2.fromOffset(sz, sz),
			BackgroundTransparency = 1,
			Text = resolved,
			TextColor3 = color or Color3.fromRGB(255, 255, 255),
			TextSize = math.floor(sz * 0.9),
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Parent = parent,
		})
		return lbl
	end
end

return Icons
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
	local stepConnection = nil

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

	local function stopStepping()
		if stepConnection then
			stepConnection:Disconnect()
			stepConnection = nil
		end
	end

	local function startStepping()
		if stepConnection then return end
		stepConnection = RunService.RenderStepped:Connect(function(dt)
			if not target.Parent then
				stopStepping()
				return
			end

			if smoothness and smoothness > 0 then
				local currentX = target.Position.X.Offset
				local currentY = target.Position.Y.Offset
				local goalX = targetPos.X.Offset
				local goalY = targetPos.Y.Offset

				local lerpX = currentX + (goalX - currentX) * math.clamp(alpha * (dt * 60), 0, 1)
				local lerpY = currentY + (goalY - currentY) * math.clamp(alpha * (dt * 60), 0, 1)

				target.Position = UDim2.new(targetPos.X.Scale, math.round(lerpX), targetPos.Y.Scale, math.round(lerpY))

				if not dragging and math.abs(goalX - currentX) < 1 and math.abs(goalY - currentY) < 1 then
					target.Position = targetPos
					stopStepping()
				end
			else
				target.Position = targetPos
				if not dragging then
					stopStepping()
				end
			end
		end)
	end

	local c1 = handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
			frameStartPos = target.Position
			targetPos = target.Position
			dragInput = input
			startStepping()

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

	if maid then
		maid:Give(c1)
		maid:Give(c2)
		maid:Give(function()
			stopStepping()
		end)
	end

	target.Destroying:Connect(function()
		c1:Disconnect()
		c2:Disconnect()
		stopStepping()
	end)
end

return Drag
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

_modules['Components.TitleStack'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local TitleStack = {}

function TitleStack.New(parent, title, subtitle)
	local container = Elements.Create("Frame", {
		Name = "TitleStack",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = container,
	})

	local titleLabel = Elements.Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = title or "",
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.RowTitle.Size,
		Font = Theme.Typography.RowTitle.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		LayoutOrder = 1,
		Parent = container,
	})
	Theme.Register(titleLabel, "TextColor3", "Text")

	local subLabel = nil
	if subtitle and subtitle ~= "" then
		subLabel = Elements.Create("TextLabel", {
			Name = "Subtitle",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text = subtitle,
			TextColor3 = Theme.Get("SecondaryText"),
			TextSize = Theme.Typography.Subtitle.Size,
			Font = Theme.Typography.Subtitle.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			LayoutOrder = 2,
			Parent = container,
		})
		Theme.Register(subLabel, "TextColor3", "SecondaryText")
	end

	return {
		Container = container,
		TitleLabel = titleLabel,
		SubtitleLabel = subLabel,
		SetTitle = function(self, newTitle)
			titleLabel.Text = newTitle
		end,
		SetSubtitle = function(self, newSub)
			if not subLabel and newSub and newSub ~= "" then
				subLabel = Elements.Create("TextLabel", {
					Name = "Subtitle",
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Text = newSub,
					TextColor3 = Theme.Get("SecondaryText"),
					TextSize = Theme.Typography.Subtitle.Size,
					Font = Theme.Typography.Subtitle.Font,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					LayoutOrder = 2,
					Parent = container,
				})
				Theme.Register(subLabel, "TextColor3", "SecondaryText")
			elseif subLabel then
				subLabel.Text = newSub or ""
				subLabel.Visible = (newSub ~= nil and newSub ~= "")
			end
		end,
	}
end

return TitleStack
end

_modules['Components.Row'] = function()
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local TitleStack = _require("Components.TitleStack")

local Row = {}

function Row.New(parent, options)
	options = options or {}
	local isTouch = UserInputService.TouchEnabled
	local minHeight = isTouch and 52 or 44

	local frame = Elements.Create("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, minHeight),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent = parent,
	})

	Elements.Padding(frame, { Top = 10, Bottom = 10, Left = 12, Right = 12 })

	local leftContainer = Elements.Create("Frame", {
		Name = "Left",
		Size = UDim2.new(0.60, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	local titleStack = nil
	if options.Title then
		titleStack = TitleStack.New(leftContainer, options.Title, options.Subtitle)
	end

	local rightContainer = Elements.Create("Frame", {
		Name = "Right",
		Size = UDim2.new(0.40, 0, 1, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	local rightLayout = Elements.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = rightContainer,
	})

	local hairline = Elements.Hairline(frame, 12)
	Theme.Register(hairline, "BackgroundColor3", "Hairline")

	local searchIndex = string.lower(options.SearchIndex or options.Title or "")

	local rowObj = {
		Frame = frame,
		LeftContainer = leftContainer,
		RightContainer = rightContainer,
		TitleStack = titleStack,
		Hairline = hairline,
		SearchIndex = searchIndex,
		Left = function(self)
			return leftContainer
		end,
		Right = function(self)
			return rightContainer
		end,
		SetTitle = function(self, title, subtitle)
			if not self.TitleStack then
				self.TitleStack = TitleStack.New(leftContainer, title, subtitle)
			else
				self.TitleStack:SetTitle(title)
				if subtitle ~= nil then
					self.TitleStack:SetSubtitle(subtitle)
				end
			end
			self.SearchIndex = string.lower(title or "")
		end,
		SetHairlineVisible = function(self, visible)
			hairline.Visible = visible
		end,
		SetVisible = function(self, visible)
			frame.Visible = visible
		end,
	}

	return rowObj
end

return Row
end

_modules['Components.Launcher'] = function()
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")
local Drag = _require("Core.Drag")

local Launcher = {}

function Launcher.New(gui, windowObj, library)
	local maid = library.Maid

	local btn = Elements.Create("TextButton", {
		Name = "VynxLauncher",
		Size = UDim2.fromOffset(48, 48),
		Position = UDim2.new(0, 20, 0.5, -24),
		BackgroundColor3 = Theme.Get("Window"),
		BackgroundTransparency = 0,
		Text = "V",
		TextColor3 = Theme.Get("Accent"),
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 1100,
		Visible = false,
		Parent = gui,
	})
	Elements.Round(btn, 24)

	local stroke = Elements.Stroke(btn, Theme.Get("Accent"), 1.5, 0.2)
	Theme.Register(btn, "BackgroundColor3", "Window")
	Theme.Register(btn, "TextColor3", "Accent")
	Theme.Register(stroke, "Color", "Accent")

	-- Subtle shadow
	local shadow = Elements.Create("ImageLabel", {
		Name = "LauncherShadow",
		Size = UDim2.new(1, 16, 1, 16),
		Position = UDim2.fromOffset(-8, -6),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217", -- Generic diffuse shadow
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = 1099,
		Parent = btn,
	})

	Drag.Make(btn, btn, 0.2, maid)

	local function onClick()
		windowObj:Toggle(true)
	end

	btn.MouseButton1Click:Connect(onClick)

	-- Hover animation
	btn.MouseEnter:Connect(function()
		Elements.Tween(btn, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), {
			BackgroundColor3 = Theme.Get("FormCard"),
		})
	end)

	btn.MouseLeave:Connect(function()
		Elements.Tween(btn, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), {
			BackgroundColor3 = Theme.Get("Window"),
		})
	end)

	local launcherObj = {
		Button = btn,
		SetVisible = function(self, visible)
			btn.Visible = visible
		end,
	}

	return launcherObj
end

return Launcher
end

_modules['Components.StatusBar'] = function()
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")

local StatusBar = {}

function StatusBar.New(parent, options, library)
	options = options or {}
	local maid = library.Maid

	local bar = Elements.Create("Frame", {
		Name = "StatusBar",
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24),
		BackgroundColor3 = Theme.Get("Sidebar"),
		BorderSizePixel = 0,
		Parent = parent,
	})
	Theme.Register(bar, "BackgroundColor3", "Sidebar")

	local topHairline = Elements.Hairline(bar, "Top")

	local padding = Elements.Padding(bar, { Top = 0, Bottom = 0, Left = 12, Right = 12 })

	local leftLabel = Elements.Create("TextLabel", {
		Name = "StatusLeft",
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = options.DefaultText or "vynx  •  ready",
		TextColor3 = Theme.Get("SecondaryText"),
		TextSize = Theme.Typography.Caption.Size,
		Font = Theme.Typography.Caption.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = bar,
	})
	Theme.Register(leftLabel, "TextColor3", "SecondaryText")

	local rightLabel = Elements.Create("TextLabel", {
		Name = "StatusRight",
		Size = UDim2.new(0.4, 0, 1, 0),
		Position = UDim2.new(0.6, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "60 fps",
		TextColor3 = Theme.Get("TertiaryText"),
		TextSize = Theme.Typography.Caption.Size,
		Font = Theme.Typography.Caption.Font,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = bar,
	})
	Theme.Register(rightLabel, "TextColor3", "TertiaryText")

	local frameCount = 0
	local lastTime = os.clock()
	local fpsConn = RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		local now = os.clock()
		if now - lastTime >= 1 then
			local fps = math.round(frameCount / (now - lastTime))
			local pingMs = 0
			pcall(function()
				local perfStats = StatsService:FindFirstChild("PerformanceStats")
				if perfStats then
					local pingStat = perfStats:FindFirstChild("Ping")
					if pingStat then
						pingMs = math.round(pingStat:GetValue())
					end
				end
			end)

			if pingMs > 0 then
				rightLabel.Text = string.format("%d fps  •  %d ms", fps, pingMs)
			else
				rightLabel.Text = string.format("%d fps", fps)
			end
			frameCount = 0
			lastTime = now
		end
	end)
	maid:Give(fpsConn)

	local statusBarObj = {
		Frame = bar,
		SetText = function(self, text)
			leftLabel.Text = text
		end,
		SetVisible = function(self, visible)
			bar.Visible = visible
		end,
	}

	return statusBarObj
end

return StatusBar
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
local Motion = _require("Core.Motion")
local Tooltip = _require("Core.Tooltip")

local Button = {}

function Button.New(parent, options)
	options = options or {}
	local callback = options.Func or options.Callback or function() end
	local originalText = options.Title or options.Text or "Button"
	local isProminent = options.Prominent or options.Variant == "Prominent"
	local waitingConfirm = false
	local confirmThread = nil

	local btn = Elements.Create("TextButton", {
		Name = originalText .. "_Btn",
		Size = UDim2.new(0, 0, 0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = isProminent and Theme.Get("Accent") or Theme.Get("ControlFill"),
		Text = originalText,
		TextColor3 = isProminent and Color3.fromRGB(255, 255, 255) or Theme.Get("Text"),
		TextSize = Theme.Typography.Subtitle.Size,
		Font = isProminent and Enum.Font.GothamBold or Theme.Typography.Subtitle.Font,
		AutoButtonColor = false,
		ClipsDescendants = true,
		Parent = parent,
	})

	Elements.Round(btn, 6)
	local stroke = Elements.Stroke(btn, isProminent and Theme.Get("Accent") or Theme.Get("Hairline"), 1, 0)
	Elements.Padding(btn, { Top = 0, Bottom = 0, Left = 14, Right = 14 })

	if isProminent then
		local themeConn = Theme.Changed:Connect(function(palette)
			btn.BackgroundColor3 = palette.Accent
			stroke.Color = palette.Accent
		end)
		btn.Destroying:Connect(function() themeConn:Disconnect() end)
	else
		Theme.Register(btn, "BackgroundColor3", "ControlFill")
		Theme.Register(btn, "TextColor3", "Text")
		Theme.Register(stroke, "Color", "Hairline")
	end

	if options.Tooltip then
		Tooltip.Attach(btn, options.Tooltip)
	end

	local uiScale = Elements.Scale(btn, 1)

	btn.MouseEnter:Connect(function()
		if not isProminent then
			Elements.Tween(btn, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), {
				BackgroundColor3 = Theme.Get("FormCard"),
			})
		end
	end)

	btn.MouseLeave:Connect(function()
		if not isProminent then
			Elements.Tween(btn, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), {
				BackgroundColor3 = Theme.Get("ControlFill"),
			})
		end
	end)

	btn.MouseButton1Click:Connect(function()
		Elements.Tween(uiScale, TweenInfo.new(0.06, Motion.Easing.QuadOut), { Scale = 0.96 })
		task.delay(0.06, function()
			Elements.Tween(uiScale, TweenInfo.new(0.1, Motion.Easing.QuadOut), { Scale = 1.0 })
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

	local btnObj = {
		Button = btn,
		SetText = function(self, text)
			originalText = text
			btn.Text = text
		end,
		SetVisible = function(self, visible)
			btn.Visible = visible
		end,
	}

	return btnObj
end

return Button
end

_modules['Components.Colorpicker'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")
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
	options = options or {}
	local currentColor = options.Default or Color3.fromRGB(10, 132, 255)
	local currentAlpha = options.Transparency or 0
	local callback = options.Callback or function() end
	local isOpen = false

	local frame = Elements.Create("Frame", {
		Name = id .. "_Colorpicker",
		Size = isEmbedded and UDim2.fromOffset(28, 20) or UDim2.new(0, 0, 0, 26),
		AutomaticSize = isEmbedded and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	if options.Tooltip then
		Tooltip.Attach(frame, options.Tooltip)
	end

	local previewBtn = Elements.Create("TextButton", {
		Name = "PreviewSwatch",
		Size = UDim2.fromOffset(28, 20),
		BackgroundColor3 = currentColor,
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
	Elements.Round(previewBtn, 5)
	local previewStroke = Elements.Stroke(previewBtn, Theme.Get("Hairline"), 1, 0)
	Theme.Register(previewStroke, "Color", "Hairline")

	-- Popover Palette Card
	local popover = Elements.Create("Frame", {
		Name = id .. "_PopoverPalette",
		Size = UDim2.fromOffset(200, 150),
		BackgroundColor3 = Theme.Get("FormCard"),
		Visible = false,
	})
	Elements.Round(popover, 8)
	local popoverStroke = Elements.Stroke(popover, Theme.Get("Hairline"), 1, 0)
	Theme.Register(popover, "BackgroundColor3", "FormCard")
	Theme.Register(popoverStroke, "Color", "Hairline")
	Elements.Padding(popover, 8)
	Elements.Shadow(popover, 2, 8, 0.45)

	local popoverLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = popover,
	})

	-- Hex Code Box
	local hexBox = Elements.Create("TextBox", {
		Name = "HexInput",
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = Theme.Get("ControlFill"),
		Text = toHex(currentColor),
		TextColor3 = Theme.Get("Text"),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
		LayoutOrder = 1,
		Parent = popover,
	})
	Elements.Round(hexBox, 4)
	Theme.Register(hexBox, "BackgroundColor3", "ControlFill")
	Theme.Register(hexBox, "TextColor3", "Text")

	-- Curated Apple Palette Swatches
	local swatchGridFrame = Elements.Create("Frame", {
		Name = "SwatchesGrid",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = popover,
	})

	local swatchLayout = Elements.Create("UIGridLayout", {
		CellSize = UDim2.fromOffset(32, 24),
		CellPadding = UDim2.fromOffset(6, 6),
		Parent = swatchGridFrame,
	})

	local appleSwatches = {
		Color3.fromRGB(10, 132, 255),  -- Blue
		Color3.fromRGB(191, 90, 242),  -- Purple
		Color3.fromRGB(255, 55, 95),   -- Pink
		Color3.fromRGB(255, 69, 58),   -- Red
		Color3.fromRGB(255, 159, 10),  -- Orange
		Color3.fromRGB(255, 214, 10),  -- Yellow
		Color3.fromRGB(48, 209, 88),   -- Green
		Color3.fromRGB(152, 152, 159), -- Graphite
		Color3.fromRGB(255, 255, 255), -- White
		Color3.fromRGB(28, 28, 30),    -- Dark Window
	}

	local colorpickerObj = {
		Frame = frame,
		Value = currentColor,
		Transparency = currentAlpha,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newCol, newAlpha)
			self.Value = newCol
			if newAlpha ~= nil then
				self.Transparency = newAlpha
			end
			previewBtn.BackgroundColor3 = newCol
			hexBox.Text = toHex(newCol)
			task.spawn(self.Callback, newCol, self.Transparency)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newCol, self.Transparency)
			end
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
		end,
	}

	for _, col in ipairs(appleSwatches) do
		local sBtn = Elements.Create("TextButton", {
			BackgroundColor3 = col,
			Text = "",
			AutoButtonColor = false,
			Parent = swatchGridFrame,
		})
		Elements.Round(sBtn, 4)
		local sStroke = Elements.Stroke(sBtn, Theme.Get("Hairline"), 1, 0)
		Theme.Register(sStroke, "Color", "Hairline")

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

	if registry then
		registry[id] = colorpickerObj
	end

	return colorpickerObj
end

return Colorpicker
end

_modules['Components.Keybind'] = function()
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")
local Tooltip = _require("Core.Tooltip")

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
end

_modules['Components.Toggle'] = function()
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")
local Tooltip = _require("Core.Tooltip")
local Colorpicker = _require("Components.Colorpicker")
local Keybind = _require("Components.Keybind")

local Toggle = {}

function Toggle.New(parent, id, options, library, isRow)
	options = options or {}
	local state = options.Default or false
	local callback = options.Callback or function() end

	local container = nil
	if isRow then
		container = Elements.Create("Frame", {
			Name = id .. "_ToggleHolder",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Parent = parent,
		})
	else
		container = Elements.Create("TextButton", {
			Name = id .. "_Toggle",
			Size = UDim2.new(1, 0, 0, 28),
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
			TextColor3 = Theme.Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextSize = Theme.Typography.RowTitle.Size,
			Font = Theme.Typography.RowTitle.Font,
			Parent = container,
		})
		Theme.Register(label, "TextColor3", "Text")
	end

	if options.Tooltip then
		Tooltip.Attach(container, options.Tooltip)
	end

	local subHolder = Elements.Create("Frame", {
		Name = "SubHolder",
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = isRow and Vector2.new(1, 0.5) or Vector2.new(1, 0.5),
		Position = isRow and UDim2.new(1, 0, 0.5, 0) or UDim2.new(1, -2, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = container,
	})

	local subLayout = Elements.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = subHolder,
	})

	-- macOS Switch Pill (40x24)
	local switchBtn = Elements.Create("TextButton", {
		Name = "SwitchPill",
		Size = UDim2.fromOffset(40, 24),
		BackgroundColor3 = state and Theme.Get("Accent") or Theme.Get("ControlFill"),
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 10,
		Parent = subHolder,
	})
	Elements.Round(switchBtn, 12)
	local switchStroke = Elements.Stroke(switchBtn, Theme.Get("Hairline"), 1, 0)
	Theme.Register(switchStroke, "Color", "Hairline")

	-- 20px Knob with subtle shadow
	local knob = Elements.Create("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = switchBtn,
	})
	Elements.Round(knob, 10)

	local knobShadow = Elements.Create("ImageLabel", {
		Name = "KnobShadow",
		Size = UDim2.new(1, 6, 1, 6),
		Position = UDim2.fromOffset(-3, -2),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.65,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = knob.ZIndex - 1,
		Parent = knob,
	})

	local isPressed = false
	local function updateVisuals(value, animate)
		local duration = animate and Motion.Duration.Base or 0
		local targetColor = value and Theme.Get("Accent") or Theme.Get("ControlFill")
		local targetPos = value and UDim2.new(1, isPressed and -26 or -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		local targetSize = isPressed and UDim2.fromOffset(24, 20) or UDim2.fromOffset(20, 20)

		if animate then
			Elements.Tween(switchBtn, TweenInfo.new(duration, Motion.Easing.QuintOut), { BackgroundColor3 = targetColor })
			Elements.Tween(knob, TweenInfo.new(duration, Motion.Easing.QuintOut), {
				Position = targetPos,
				Size = targetSize,
			})
		else
			switchBtn.BackgroundColor3 = targetColor
			knob.Position = targetPos
			knob.Size = targetSize
		end
	end

	local themeConn = Theme.Changed:Connect(function(palette)
		if state then
			switchBtn.BackgroundColor3 = palette.Accent
		else
			switchBtn.BackgroundColor3 = palette.ControlFill
		end
	end)

	local toggleObj = {
		Value = state,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newValue)
			if self.Value == newValue then return end
			self.Value = newValue
			state = newValue
			updateVisuals(newValue, true)
			task.spawn(self.Callback, newValue)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newValue)
			end
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
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

	-- Knob stretch micro-interaction
	switchBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isPressed = true
			Elements.Tween(knob, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), {
				Size = UDim2.fromOffset(24, 20),
				Position = state and UDim2.new(1, -26, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			})
		end
	end)

	switchBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isPressed = false
			Elements.Tween(knob, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuintOut), {
				Size = UDim2.fromOffset(20, 20),
				Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			})
		end
	end)

	switchBtn.MouseButton1Click:Connect(function()
		toggleObj:SetValue(not toggleObj.Value)
	end)

	if not isRow then
		container.MouseButton1Click:Connect(function()
			toggleObj:SetValue(not toggleObj.Value)
		end)
	end

	container.Destroying:Connect(function()
		themeConn:Disconnect()
	end)

	if library and library.Toggles then
		library.Toggles[id] = toggleObj
	end

	return toggleObj
end

return Toggle
end

_modules['Components.Slider'] = function()
local UserInputService = game:GetService("UserInputService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")
local Tooltip = _require("Core.Tooltip")

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
end

_modules['Components.Input'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")
local Tooltip = _require("Core.Tooltip")

local Input = {}

function Input.New(parent, id, options, registry, isRow)
	options = options or {}
	local currentText = options.Default or ""
	local callback = options.Callback or function() end
	local isFinishedMode = true
	if options.Finished ~= nil then
		isFinishedMode = options.Finished
	end

	local container = nil
	local inputBg = nil

	if isRow then
		container = Elements.Create("Frame", {
			Name = id .. "_InputHolder",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = parent,
		})

		inputBg = Elements.Create("Frame", {
			Name = "InputBg",
			Size = UDim2.new(1, 0, 0, 28),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Theme.Get("ControlFill"),
			Parent = container,
		})
	else
		container = Elements.Create("Frame", {
			Name = id .. "_Input",
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundTransparency = 1,
			Parent = parent,
		})

		local label = Elements.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Text = options.Text or id,
			TextColor3 = Theme.Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = Theme.Typography.RowTitle.Size,
			Font = Theme.Typography.RowTitle.Font,
			Parent = container,
		})
		Theme.Register(label, "TextColor3", "Text")

		inputBg = Elements.Create("Frame", {
			Name = "InputBg",
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 0, 20),
			BackgroundColor3 = Theme.Get("ControlFill"),
			Parent = container,
		})
	end

	Elements.Round(inputBg, 6)
	local stroke = Elements.Stroke(inputBg, Theme.Get("Hairline"), 1, 0)
	Theme.Register(inputBg, "BackgroundColor3", "ControlFill")
	Theme.Register(stroke, "Color", "Hairline")

	if options.Tooltip then
		Tooltip.Attach(container, options.Tooltip)
	end

	local textBox = Elements.Create("TextBox", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = currentText,
		PlaceholderText = options.Placeholder or "Enter text...",
		PlaceholderColor3 = Theme.Get("TertiaryText"),
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.Subtitle.Size,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Theme.Typography.Subtitle.Font,
		ClearTextOnFocus = false,
		Parent = inputBg,
	})
	Theme.Register(textBox, "TextColor3", "Text")
	Theme.Register(textBox, "PlaceholderColor3", "TertiaryText")

	local lastFiredText = currentText

	local inputObj = {
		Value = currentText,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newText)
			newText = tostring(newText or "")
			if self.Value == newText and textBox.Text == newText then return end
			self.Value = newText
			textBox.Text = newText
			lastFiredText = newText
			task.spawn(self.Callback, newText)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newText)
			end
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
		end,
	}

	textBox.Focused:Connect(function()
		Elements.Tween(stroke, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), { Color = Theme.Get("Accent") })
	end)

	local function processText()
		local text = textBox.Text
		if options.Numeric then
			text = string.gsub(text, "[^%d.-]", "")
			textBox.Text = text
		end
		if text ~= lastFiredText then
			lastFiredText = text
			inputObj.Value = text
			task.spawn(inputObj.Callback, text)
			for _, fn in ipairs(inputObj.ChangedCallbacks) do
				task.spawn(fn, text)
			end
		end
	end

	if isFinishedMode then
		textBox.FocusLost:Connect(function()
			Elements.Tween(stroke, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), { Color = Theme.Get("Hairline") })
			processText()
		end)
	else
		textBox.FocusLost:Connect(function()
			Elements.Tween(stroke, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadOut), { Color = Theme.Get("Hairline") })
		end)

		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			processText()
		end)
	end

	if registry then
		registry[id] = inputObj
	end

	return inputObj
end

return Input
end

_modules['Components.Stepper'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")

local Stepper = {}

function Stepper.New(parent, id, options, registry)
	options = options or {}
	local minVal = options.Min or 0
	local maxVal = options.Max or 100
	local step = options.Step or 1
	local currentVal = math.clamp(options.Default or minVal, minVal, maxVal)
	local callback = options.Callback or function() end
	local suffix = options.Suffix or ""

	local container = Elements.Create("Frame", {
		Name = id .. "_StepperHolder",
		Size = UDim2.new(0, 0, 0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local layout = Elements.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = container,
	})

	local valLabel = Elements.Create("TextLabel", {
		Name = "ValueLabel",
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = tostring(currentVal) .. suffix,
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.Subtitle.Size,
		Font = Theme.Typography.Subtitle.Font,
		Parent = container,
	})
	Theme.Register(valLabel, "TextColor3", "Text")

	local capsule = Elements.Create("Frame", {
		Name = "StepperCapsule",
		Size = UDim2.fromOffset(56, 28),
		BackgroundColor3 = Theme.Get("ControlFill"),
		ClipsDescendants = true,
		Parent = container,
	})
	Elements.Round(capsule, 6)
	local stroke = Elements.Stroke(capsule, Theme.Get("Hairline"), 1, 0)
	Theme.Register(capsule, "BackgroundColor3", "ControlFill")
	Theme.Register(stroke, "Color", "Hairline")

	local minusBtn = Elements.Create("TextButton", {
		Name = "Minus",
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "−",
		TextColor3 = Theme.Get("Text"),
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		Parent = capsule,
	})
	Theme.Register(minusBtn, "TextColor3", "Text")

	local divider = Elements.Create("Frame", {
		Name = "Divider",
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundColor3 = Theme.Get("Hairline"),
		BorderSizePixel = 0,
		Parent = capsule,
	})
	Theme.Register(divider, "BackgroundColor3", "Hairline")

	local plusBtn = Elements.Create("TextButton", {
		Name = "Plus",
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "+",
		TextColor3 = Theme.Get("Text"),
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		Parent = capsule,
	})
	Theme.Register(plusBtn, "TextColor3", "Text")

	local stepperObj = {
		Value = currentVal,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newVal)
			local clamped = math.clamp(newVal, minVal, maxVal)
			if clamped == self.Value then return end
			self.Value = clamped
			valLabel.Text = tostring(clamped) .. suffix
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

	minusBtn.MouseButton1Click:Connect(function()
		stepperObj:SetValue(stepperObj.Value - step)
	end)

	plusBtn.MouseButton1Click:Connect(function()
		stepperObj:SetValue(stepperObj.Value + step)
	end)

	if registry then
		registry[id] = stepperObj
	end

	return stepperObj
end

return Stepper
end

_modules['Components.Segmented'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")

local Segmented = {}

function Segmented.New(parent, id, options, registry)
	options = options or {}
	local items = options.Values or options.Options or {}
	local selected = options.Default or items[1] or ""
	local callback = options.Callback or function() end

	local totalItems = math.max(#items, 1)

	local container = Elements.Create("Frame", {
		Name = id .. "_Segmented",
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Theme.Get("ControlFill"),
		ClipsDescendants = false,
		Parent = parent,
	})
	Elements.Round(container, 6)
	local stroke = Elements.Stroke(container, Theme.Get("Hairline"), 1, 0)
	Theme.Register(container, "BackgroundColor3", "ControlFill")
	Theme.Register(stroke, "Color", "Hairline")
	Elements.Padding(container, { Top = 2, Bottom = 2, Left = 2, Right = 2 })

	-- Selection Sliding Pill
	local itemWidth = 1 / totalItems
	local activeIndex = 1
	for idx, val in ipairs(items) do
		if val == selected then
			activeIndex = idx
			break
		end
	end

	local indicator = Elements.Create("Frame", {
		Name = "Indicator",
		Size = UDim2.new(itemWidth, 0, 1, 0),
		Position = UDim2.new(itemWidth * (activeIndex - 1), 0, 0, 0),
		BackgroundColor3 = Theme.Get("FormCard"),
		ZIndex = 2,
		Parent = container,
	})
	Elements.Round(indicator, 5)
	local indicatorStroke = Elements.Stroke(indicator, Theme.Get("Hairline"), 1, 0.5)
	Theme.Register(indicator, "BackgroundColor3", "FormCard")
	Theme.Register(indicatorStroke, "Color", "Hairline")

	local buttons = {}
	local segmentedObj = {
		Value = selected,
		Callback = callback,
		ChangedCallbacks = {},
		SetValue = function(self, newVal)
			local foundIndex = nil
			for idx, val in ipairs(items) do
				if val == newVal then
					foundIndex = idx
					break
				end
			end
			if not foundIndex or self.Value == newVal then return end

			self.Value = newVal
			Elements.Tween(indicator, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuintOut), {
				Position = UDim2.new(itemWidth * (foundIndex - 1), 0, 0, 0),
			})

			for idx, btn in ipairs(buttons) do
				btn.TextColor3 = (idx == foundIndex) and Theme.Get("Text") or Theme.Get("SecondaryText")
				btn.Font = (idx == foundIndex) and Enum.Font.GothamBold or Enum.Font.GothamMedium
			end

			task.spawn(self.Callback, newVal)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newVal)
			end
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
		end,
	}

	for idx, itemText in ipairs(items) do
		local btn = Elements.Create("TextButton", {
			Name = "Segment_" .. idx,
			Size = UDim2.new(itemWidth, 0, 1, 0),
			Position = UDim2.new(itemWidth * (idx - 1), 0, 0, 0),
			BackgroundTransparency = 1,
			Text = tostring(itemText),
			TextColor3 = (idx == activeIndex) and Theme.Get("Text") or Theme.Get("SecondaryText"),
			TextSize = Theme.Typography.Subtitle.Size,
			Font = (idx == activeIndex) and Enum.Font.GothamBold or Enum.Font.GothamMedium,
			AutoButtonColor = false,
			ZIndex = 3,
			Parent = container,
		})

		btn.MouseButton1Click:Connect(function()
			segmentedObj:SetValue(itemText)
		end)

		table.insert(buttons, btn)
	end

	if registry then
		registry[id] = segmentedObj
	end

	return segmentedObj
end

return Segmented
end

_modules['Components.Dropdown'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")
local Tooltip = _require("Core.Tooltip")
local Popover = _require("Components.Popover")

local Dropdown = {}

function Dropdown.New(parent, id, options, registry, isRow)
	options = options or {}
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

	local container = nil
	local box = nil

	if isRow then
		container = Elements.Create("Frame", {
			Name = id .. "_DropdownHolder",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Parent = parent,
		})

		box = Elements.Create("TextButton", {
			Name = "SelectButton",
			Size = UDim2.new(0, 160, 0, 28),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Theme.Get("ControlFill"),
			Text = "",
			AutoButtonColor = false,
			Parent = container,
		})
	else
		container = Elements.Create("Frame", {
			Name = id .. "_Dropdown",
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundTransparency = 1,
			Parent = parent,
		})

		local label = Elements.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Text = options.Text or id,
			TextColor3 = Theme.Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = Theme.Typography.RowTitle.Size,
			Font = Theme.Typography.RowTitle.Font,
			Parent = container,
		})
		Theme.Register(label, "TextColor3", "Text")

		box = Elements.Create("TextButton", {
			Name = "SelectButton",
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 0, 22),
			BackgroundColor3 = Theme.Get("ControlFill"),
			Text = "",
			AutoButtonColor = false,
			Parent = container,
		})
	end

	Elements.Round(box, 6)
	local boxStroke = Elements.Stroke(box, Theme.Get("Hairline"), 1, 0)
	Theme.Register(box, "BackgroundColor3", "ControlFill")
	Theme.Register(boxStroke, "Color", "Hairline")

	if options.Tooltip then
		Tooltip.Attach(container, options.Tooltip)
	end

	local valLabel = Elements.Create("TextLabel", {
		Name = "ValueLabel",
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = Theme.Typography.Subtitle.Size,
		Font = Theme.Typography.Subtitle.Font,
		Parent = box,
	})
	Theme.Register(valLabel, "TextColor3", "Text")

	local arrow = Elements.Create("TextLabel", {
		Name = "Chevron",
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -22, 0, 0),
		BackgroundTransparency = 1,
		Text = "⌄",
		TextColor3 = Theme.Get("SecondaryText"),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Parent = box,
	})
	Theme.Register(arrow, "TextColor3", "SecondaryText")

	-- Popover List Floating Card
	local listFrame = Elements.Create("Frame", {
		Name = id .. "_PopoverList",
		Size = UDim2.new(0, 200, 0, 180),
		BackgroundColor3 = Theme.Get("FormCard"),
		Visible = false,
	})
	Elements.Round(listFrame, 8)
	local listStroke = Elements.Stroke(listFrame, Theme.Get("Hairline"), 1, 0)
	Theme.Register(listFrame, "BackgroundColor3", "FormCard")
	Theme.Register(listStroke, "Color", "Hairline")
	Elements.Padding(listFrame, 6)

	-- Procedural shadow for popup
	Elements.Shadow(listFrame, 2, 8, 0.45)

	local listLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = listFrame,
	})

	local searchBox = Elements.Create("TextBox", {
		Name = "SearchBox",
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = Theme.Get("ControlFill"),
		PlaceholderText = "Search...",
		PlaceholderColor3 = Theme.Get("TertiaryText"),
		TextColor3 = Theme.Get("Text"),
		Text = "",
		TextSize = 12,
		Font = Theme.Typography.Subtitle.Font,
		Visible = #values > 8,
		LayoutOrder = 1,
		Parent = listFrame,
	})
	Elements.Round(searchBox, 4)
	Theme.Register(searchBox, "BackgroundColor3", "ControlFill")
	Theme.Register(searchBox, "TextColor3", "Text")
	Theme.Register(searchBox, "PlaceholderColor3", "TertiaryText")

	local scrollContainer = Elements.Create("ScrollingFrame", {
		Name = "ItemsScroll",
		Size = UDim2.new(1, 0, 1, #values > 8 and -30 or 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
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
		ChangedCallbacks = {},
		SetValue = function(self, newVal)
			self.Value = newVal
			currentValue = newVal
			valLabel.Text = getDisplayText()
			task.spawn(self.Callback, newVal)
			for _, fn in ipairs(self.ChangedCallbacks) do
				task.spawn(fn, newVal)
			end
		end,
		SetValues = function(self, newValues)
			self.Values = newValues
			values = newValues
		end,
		OnChanged = function(self, fn)
			table.insert(self.ChangedCallbacks, fn)
			return self
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
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundColor3 = isSelected and Theme.Get("Accent") or Theme.Get("ControlFill"),
					BackgroundTransparency = isSelected and 0 or 1,
					Text = (isSelected and "  ✓ " or "    ") .. itemVal,
					TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Theme.Get("Text"),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 12,
					Font = isSelected and Enum.Font.GothamBold or Theme.Typography.Subtitle.Font,
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
						arrow.Text = "⌄"
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
		arrow.Text = isOpen and "⌃" or "⌄"
		if isOpen then
			local targetW = math.max(box.AbsoluteSize.X, 180)
			local count = math.min(#dropdownObj.Values, 7)
			local targetH = math.clamp(count * 28 + (#dropdownObj.Values > 8 and 38 or 12), 60, 240)
			listFrame.Size = UDim2.fromOffset(targetW, targetH)
			refreshItems("")
			Popover.Open(listFrame, box, function()
				isOpen = false
				arrow.Text = "⌄"
			end)
		else
			Popover.Close()
		end
	end)

	container.Destroying:Connect(function()
		themeConn:Disconnect()
		listFrame:Destroy()
	end)

	if registry then
		registry[id] = dropdownObj
	end

	return dropdownObj
end

return Dropdown
end

_modules['Components.Notification'] = function()
local TweenService = game:GetService("TweenService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")

local Notification = {}

local holder = nil
local activeQueue = {}
local MAX_NOTIFICATIONS = 4

function Notification.Init(gui)
	if holder and holder.Parent then return end

	holder = Elements.Create("Frame", {
		Name = "VynxNotificationCenter",
		Size = UDim2.new(0, 320, 1, -40),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 20),
		BackgroundTransparency = 1,
		ZIndex = 1200,
		Parent = gui,
	})

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 10),
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

	local duration = info.Duration or 4.0
	local nType = info.Type or "Info"

	local typeColors = {
		Info = Theme.Get("Accent"),
		Success = Theme.Get("Success"),
		Warn = Theme.Get("Warning"),
		Error = Theme.Get("Danger"),
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
		Name = "ToastCard",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Get("FormCard"),
		Position = UDim2.new(1, 340, 0, 0),
		ZIndex = 1201,
		Parent = wrapper,
	})
	Elements.Round(toast, 10)
	local stroke = Elements.Stroke(toast, Theme.Get("Hairline"), 1, 0)
	Theme.Register(toast, "BackgroundColor3", "FormCard")
	Theme.Register(stroke, "Color", "Hairline")
	Elements.Padding(toast, { Top = 10, Bottom = 12, Left = 14, Right = 14 })
	Elements.Shadow(toast, 3, 10, 0.5)

	local contentLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = toast,
	})

	-- Header Row (Icon/Type + Title + Dismiss)
	local header = Elements.Create("Frame", {
		Name = "ToastHeader",
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = toast,
	})

	local dot = Elements.Create("Frame", {
		Size = UDim2.fromOffset(8, 8),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = typeColor,
		Parent = header,
	})
	Elements.Round(dot, 4)

	local titleLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text = info.Title or nType,
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.RowTitle.Size,
		Font = Theme.Typography.RowTitle.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	Theme.Register(titleLabel, "TextColor3", "Text")

	local contentLabel = Elements.Create("TextLabel", {
		Name = "ToastBody",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = info.Content or info.Text or "",
		TextColor3 = Theme.Get("SecondaryText"),
		TextSize = Theme.Typography.Subtitle.Size,
		Font = Theme.Typography.Subtitle.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		LayoutOrder = 2,
		ZIndex = 1202,
		Parent = toast,
	})
	Theme.Register(contentLabel, "TextColor3", "SecondaryText")

	local barBg = Elements.Create("Frame", {
		Name = "ProgressBarBg",
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Theme.Get("ControlFill"),
		LayoutOrder = 3,
		ZIndex = 1202,
		Parent = toast,
	})
	Elements.Round(barBg, 1)

	local progress = Elements.Create("Frame", {
		Name = "ProgressBar",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = typeColor,
		ZIndex = 1203,
		Parent = barBg,
	})
	Elements.Round(progress, 1)

	-- Slide In animation
	Elements.Tween(toast, TweenInfo.new(Motion.Duration.Slow, Motion.Easing.QuintOut), {
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
			local outTween = Elements.Tween(toast, TweenInfo.new(Motion.Duration.Base, Motion.Easing.QuadIn), {
				Position = UDim2.new(1, 340, 0, 0),
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

_modules['Components.Form'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Row = _require("Components.Row")

local Form = {}

function Form.New(parent, library)
	local card = Elements.Create("Frame", {
		Name = "FormCard",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Get("FormCard"),
		ClipsDescendants = false,
		Parent = parent,
	})
	Elements.Round(card, 10)
	local stroke = Elements.Stroke(card, Theme.Get("Hairline"), 1, 0)
	Theme.Register(card, "BackgroundColor3", "FormCard")
	Theme.Register(stroke, "Color", "Hairline")

	local cardLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0),
		Parent = card,
	})

	local rows = {}

	local formObj = {
		Frame = card,
		Rows = rows,
		AddRow = function(self, options)
			local r = Row.New(card, options)
			table.insert(rows, r)
			-- Update hairline visibility on last row
			for i, rowItem in ipairs(rows) do
				rowItem:SetHairlineVisible(i < #rows)
			end
			return r
		end,
		AddToggle = function(self, id, options)
			local Toggle = _require("Components.Toggle")
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local toggleControl = Toggle.New(r:Right(), id, options, library, true)
			return toggleControl
		end,
		AddSlider = function(self, id, options)
			local Slider = _require("Components.Slider")
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			-- Slider takes full right half or custom width
			r.LeftContainer.Size = UDim2.new(0.45, -8, 0, 0)
			r.RightContainer.Size = UDim2.new(0.55, 0, 1, 0)
			local sliderControl = Slider.New(r:Right(), id, options, library.Options, true)
			return sliderControl
		end,
		AddButton = function(self, options)
			local Button = _require("Components.Button")
			local r = self:AddRow({
				Title = options.Title or options.Text or "Action",
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text,
			})
			local btnControl = Button.New(r:Right(), options)
			return btnControl
		end,
		AddDropdown = function(self, id, options)
			local Dropdown = _require("Components.Dropdown")
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local dropdownControl = Dropdown.New(r:Right(), id, options, library.Options, true)
			return dropdownControl
		end,
		AddColorpicker = function(self, id, options)
			local Colorpicker = _require("Components.Colorpicker")
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local cpControl = Colorpicker.New(r:Right(), id, options, library.Options, true)
			return cpControl
		end,
		AddKeybind = function(self, id, options)
			local Keybind = _require("Components.Keybind")
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local kbControl = Keybind.New(r:Right(), id, options, library.Options, true)
			return kbControl
		end,
		AddInput = function(self, id, options)
			local Input = _require("Components.Input")
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			r.LeftContainer.Size = UDim2.new(0.45, -8, 0, 0)
			r.RightContainer.Size = UDim2.new(0.55, 0, 1, 0)
			local inputControl = Input.New(r:Right(), id, options, library.Options, true)
			return inputControl
		end,
		AddStepper = function(self, id, options)
			local Stepper = _require("Components.Stepper")
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local stepControl = Stepper.New(r:Right(), id, options, library.Options)
			return stepControl
		end,
		AddSegmented = function(self, id, options)
			local Segmented = _require("Components.Segmented")
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			r.LeftContainer.Size = UDim2.new(0.45, -8, 0, 0)
			r.RightContainer.Size = UDim2.new(0.55, 0, 1, 0)
			local segControl = Segmented.New(r:Right(), id, options, library.Options)
			return segControl
		end,
		AddDivider = function(self)
			local r = self:AddRow({})
			r.Frame.Size = UDim2.new(1, 0, 0, 1)
			return r
		end,
		AddLabel = function(self, text, subtitle)
			local r = self:AddRow({
				Title = text,
				Subtitle = subtitle,
				SearchIndex = text,
			})
			return r
		end,
		AddDependencyBox = function(self, parentToggle)
			local depHolder = Elements.Create("Frame", {
				Name = "DependencyHolder",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Visible = parentToggle.Value == true,
				Parent = card,
			})
			local depForm = Form.New(depHolder, library)
			if parentToggle.OnChanged then
				parentToggle:OnChanged(function(val)
					depHolder.Visible = (val == true)
				end)
			else
				local oldCb = parentToggle.Callback
				parentToggle.Callback = function(val)
					depHolder.Visible = (val == true)
					if oldCb then oldCb(val) end
				end
			end
			return depForm
		end,
	}

	return formObj
end

return Form
end

_modules['Components.PageSection'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Form = _require("Components.Form")

local PageSection = {}

function PageSection.New(parent, options, library)
	options = options or {}
	local title = options.Title or ""
	local subtitle = options.Subtitle

	local sectionFrame = Elements.Create("Frame", {
		Name = (title ~= "" and title or "PageSection") .. "_Container",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = sectionFrame,
	})

	if title and title ~= "" then
		local headerHolder = Elements.Create("Frame", {
			Name = "HeaderHolder",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = sectionFrame,
		})
		Elements.Padding(headerHolder, { Top = 0, Bottom = 2, Left = 4, Right = 4 })

		local headerLayout = Elements.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
			Parent = headerHolder,
		})

		local headingLabel = Elements.Create("TextLabel", {
			Name = "SectionHeading",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Theme.Get("SecondaryText"),
			TextSize = Theme.Typography.SectionHeading.Size,
			Font = Theme.Typography.SectionHeading.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			Parent = headerHolder,
		})
		Theme.Register(headingLabel, "TextColor3", "SecondaryText")

		if subtitle and subtitle ~= "" then
			local subLabel = Elements.Create("TextLabel", {
				Name = "SectionSubtitle",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text = subtitle,
				TextColor3 = Theme.Get("TertiaryText"),
				TextSize = Theme.Typography.Subtitle.Size,
				Font = Theme.Typography.Subtitle.Font,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				LayoutOrder = 2,
				Parent = headerHolder,
			})
			Theme.Register(subLabel, "TextColor3", "TertiaryText")
		end
	end

	local formHolder = Elements.Create("Frame", {
		Name = "FormHolder",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = sectionFrame,
	})

	local formListLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = formHolder,
	})

	local forms = {}
	local defaultForm = nil

	local sectionObj = {
		Frame = sectionFrame,
		Forms = forms,
		AddForm = function(self)
			local f = Form.New(formHolder, library)
			table.insert(forms, f)
			if not defaultForm then defaultForm = f end
			return f
		end,
		-- Direct shortcuts delegate to default form
		AddToggle = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddToggle(id, opts)
		end,
		AddSlider = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddSlider(id, opts)
		end,
		AddButton = function(self, opts)
			local f = defaultForm or self:AddForm()
			return f:AddButton(opts)
		end,
		AddDropdown = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddDropdown(id, opts)
		end,
		AddColorpicker = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddColorpicker(id, opts)
		end,
		AddKeybind = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddKeybind(id, opts)
		end,
		AddInput = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddInput(id, opts)
		end,
		AddStepper = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddStepper(id, opts)
		end,
		AddSegmented = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddSegmented(id, opts)
		end,
		AddDivider = function(self)
			local f = defaultForm or self:AddForm()
			return f:AddDivider()
		end,
		AddLabel = function(self, text, sub)
			local f = defaultForm or self:AddForm()
			return f:AddLabel(text, sub)
		end,
		AddDependencyBox = function(self, toggle)
			local f = defaultForm or self:AddForm()
			return f:AddDependencyBox(toggle)
		end,
	}

	return sectionObj
end

return PageSection
end

_modules['Components.Page'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local PageSection = _require("Components.PageSection")
local Form = _require("Components.Form")

local Page = {}

function Page.New(parent, title, library)
	local scrollFrame = Elements.Create("ScrollingFrame", {
		Name = (title or "Page") .. "_Scroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Get("ControlFill"),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ClipsDescendants = true,
		Parent = parent,
	})

	Elements.Padding(scrollFrame, { Top = 20, Bottom = 24, Left = 24, Right = 24 })

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 18),
		Parent = scrollFrame,
	})

	-- Large Page Title at top of each page
	local titleLabel = Elements.Create("TextLabel", {
		Name = "LargePageTitle",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Text = title or "Settings",
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.PageTitle.Size,
		Font = Theme.Typography.PageTitle.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		Parent = scrollFrame,
	})
	Theme.Register(titleLabel, "TextColor3", "Text")

	local sections = {}

	local pageObj = {
		Frame = scrollFrame,
		Title = title,
		Sections = sections,
		AddPageSection = function(self, options)
			if typeof(options) == "string" then
				options = { Title = options }
			end
			local sec = PageSection.New(scrollFrame, options, library)
			sec.Frame.LayoutOrder = #sections + 2
			table.insert(sections, sec)
			return sec
		end,
		AddForm = function(self)
			local sec = self:AddPageSection({})
			return sec:AddForm()
		end,
		Show = function(self)
			scrollFrame.Visible = true
		end,
		Hide = function(self)
			scrollFrame.Visible = false
		end,
	}

	return pageObj
end

return Page
end

_modules['Components.Tab'] = function()
local Page = _require("Components.Page")

local Tab = {}

function Tab.New(parent, name, library)
	local page = Page.New(parent, name, library)

	local tabObj = {
		Name = name,
		Page = page,
		AddPageSection = function(self, options)
			return page:AddPageSection(options)
		end,
		AddForm = function(self)
			return page:AddForm()
		end,
		-- Backward compatibility aliases: AddLeftGroupbox & AddRightGroupbox
		-- create a PageSection + Form in the single scrolling column (left first, then right)
		AddLeftGroupbox = function(self, title)
			return page:AddPageSection({ Title = title })
		end,
		AddRightGroupbox = function(self, title)
			return page:AddPageSection({ Title = title })
		end,
		Show = function(self)
			page:Show()
		end,
		Hide = function(self)
			page:Hide()
		end,
	}

	return tabObj
end

return Tab
end

_modules['Components.Section'] = function()
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Icons = _require("Core.Icons")
local Tab = _require("Components.Tab")

local Section = {}

function Section.New(sidebarContainer, pagesHolder, sectionTitle, windowObj, library)
	local sectionFrame = Elements.Create("Frame", {
		Name = (sectionTitle ~= "" and sectionTitle or "Section") .. "_Sidebar",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = sidebarContainer,
	})

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = sectionFrame,
	})

	if sectionTitle and sectionTitle ~= "" then
		local headerLabel = Elements.Create("TextLabel", {
			Name = "SectionHeader",
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Text = string.upper(sectionTitle),
			TextColor3 = Theme.Get("SecondaryText"),
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			Parent = sectionFrame,
		})
		Elements.Padding(headerLabel, { Top = 4, Bottom = 2, Left = 10, Right = 10 })
		Theme.Register(headerLabel, "TextColor3", "SecondaryText")
	end

	local tabsContainer = Elements.Create("Frame", {
		Name = "TabsContainer",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = sectionFrame,
	})

	local tabsLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
		Parent = tabsContainer,
	})

	local sectionObj = {
		Frame = sectionFrame,
		Title = sectionTitle,
		AddTab = function(self, options)
			if typeof(options) == "string" then
				options = { Title = options }
			end
			local title = options.Title or "Tab"
			local iconName = options.Icon
			local isSelected = options.Selected or false

			local tabObj = Tab.New(pagesHolder, title, library)

			local btn = Elements.Create("TextButton", {
				Name = title .. "_TabBtn",
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = Theme.Get("Accent"),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = tabsContainer,
			})
			Elements.Round(btn, 6)
			Elements.Padding(btn, { Top = 0, Bottom = 0, Left = 10, Right = 10 })

			local btnLayout = Elements.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8),
				Parent = btn,
			})

			local iconObj = nil
			if iconName then
				iconObj = Icons.Render(iconName, btn, 16, Theme.Get("SecondaryText"))
			end

			local textLabel = Elements.Create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, iconObj and -24 or 0, 1, 0),
				BackgroundTransparency = 1,
				Text = title,
				TextColor3 = Theme.Get("SecondaryText"),
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = btn,
			})

			local entry = {
				Title = title,
				Tab = tabObj,
				Btn = btn,
				Icon = iconObj,
				Label = textLabel,
			}

			local function selectTab()
				windowObj:SelectTab(entry)
			end

			btn.MouseButton1Click:Connect(selectTab)
			table.insert(windowObj.AllTabs, entry)

			if isSelected or #windowObj.AllTabs == 1 then
				selectTab()
			end

			return tabObj
		end,
	}

	return sectionObj
end

return Section
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

_modules['Components.Window'] = function()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Elements = _require("Core.Elements")
local Theme = _require("Core.Theme")
local Motion = _require("Core.Motion")
local Drag = _require("Core.Drag")
local Section = _require("Components.Section")
local Tab = _require("Components.Tab")
local StatusBar = _require("Components.StatusBar")
local Launcher = _require("Components.Launcher")

local Window = {}

function Window.New(gui, options, library)
	options = options or {}
	local baseSize = options.Size or UDim2.fromOffset(720, 480)
	local sidebarWidth = options.SidebarWidth or 200
	local toggleKey = options.Keybind or Enum.KeyCode.RightControl
	local isVisible = true
	local isMaximized = false
	local previousSize = baseSize
	local previousPosition = UDim2.fromScale(0.5, 0.5)
	local maid = library.Maid

	if options.Theme then
		Theme.SetTheme(options.Theme)
	end
	if options.Accent then
		Theme.SetAccent(options.Accent)
	end

	-- Root Window Frame
	local main = Elements.Create("Frame", {
		Name = "MainWindow",
		Size = baseSize,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Theme.Get("Window"),
		ClipsDescendants = false,
		Parent = gui,
	})
	Elements.Round(main, 12)

	local mainStroke = Elements.Stroke(main, Theme.Get("WindowStroke"), 1, 0)
	Theme.Register(main, "BackgroundColor3", "Window")
	Theme.Register(mainStroke, "Color", "WindowStroke")

	-- Soft 3-layer drop shadow
	if options.Dropshadow ~= false then
		Elements.Shadow(main, 3, 12, 0.55)
	end

	local mainScale = Elements.Scale(main, 1)

	-- Responsive Auto-Scale for small screens & mobile
	local function updateResponsiveScale()
		local camera = workspace.CurrentCamera
		if camera then
			local vp = camera.ViewportSize
			local targetW = baseSize.X.Offset
			if vp.X < targetW + 40 then
				local s = math.clamp((vp.X - 32) / targetW, 0.55, 1.0)
				mainScale.Scale = s
			else
				mainScale.Scale = 1.0
			end
		end
	end
	updateResponsiveScale()

	local cameraConn = workspace.CurrentCamera and workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
	if cameraConn then maid:Give(cameraConn) end

	-- Window Shell Containers
	-- 1. Topbar (macOS Sequoia Titlebar, height 44px)
	local topbar = Elements.Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Parent = main,
	})

	Drag.Make(main, topbar, 0.25, maid)

	local topDivider = Elements.Hairline(topbar, "Bottom")
	Theme.Register(topDivider, "BackgroundColor3", "Hairline")

	-- Traffic-Light Buttons (Left)
	local trafficContainer = Elements.Create("Frame", {
		Name = "TrafficLights",
		Size = UDim2.fromOffset(64, 16),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = topbar,
	})

	local trafficLayout = Elements.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = trafficContainer,
	})

	local function makeTrafficButton(name, color, symbol, order)
		local btn = Elements.Create("TextButton", {
			Name = name,
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = color,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = order,
			Parent = trafficContainer,
		})
		Elements.Round(btn, 6)

		local glyph = Elements.Create("TextLabel", {
			Name = "Glyph",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = symbol,
			TextColor3 = Color3.fromRGB(40, 20, 20),
			TextSize = 9,
			Font = Enum.Font.GothamBold,
			Visible = false,
			Parent = btn,
		})

		return btn, glyph
	end

	local closeBtn, closeGlyph = makeTrafficButton("CloseBtn", Color3.fromRGB(255, 95, 87), "✕", 1)
	local minBtn, minGlyph = makeTrafficButton("MinBtn", Color3.fromRGB(254, 188, 46), "−", 2)
	local maxBtn, maxGlyph = makeTrafficButton("MaxBtn", Color3.fromRGB(40, 200, 64), "+", 3)

	-- Hover reveals traffic-light glyphs
	local function setGlyphsVisible(vis)
		closeGlyph.Visible = vis
		minGlyph.Visible = vis
		maxGlyph.Visible = vis
	end

	trafficContainer.MouseEnter:Connect(function() setGlyphsVisible(true) end)
	trafficContainer.MouseLeave:Connect(function() setGlyphsVisible(false) end)

	-- Title in Topbar (Subtle macOS style)
	local windowTitleLabel = Elements.Create("TextLabel", {
		Name = "WindowTitle",
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0, 92, 0, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "Settings",
		TextColor3 = Theme.Get("SecondaryText"),
		TextSize = Theme.Typography.SectionHeading.Size,
		Font = Theme.Typography.SectionHeading.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	})
	Theme.Register(windowTitleLabel, "TextColor3", "SecondaryText")

	-- Search Field (macOS Search Bar on Right)
	local searchContainer = Elements.Create("Frame", {
		Name = "SearchField",
		Size = UDim2.new(0, 180, 0, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		BackgroundColor3 = Theme.Get("ControlFill"),
		Parent = topbar,
	})
	Elements.Round(searchContainer, 6)
	local searchStroke = Elements.Stroke(searchContainer, Theme.Get("Hairline"), 1, 0)
	Theme.Register(searchContainer, "BackgroundColor3", "ControlFill")
	Theme.Register(searchStroke, "Color", "Hairline")

	local searchIcon = Elements.Create("TextLabel", {
		Name = "SearchIcon",
		Size = UDim2.fromOffset(24, 28),
		BackgroundTransparency = 1,
		Text = "⌕",
		TextColor3 = Theme.Get("TertiaryText"),
		TextSize = 15,
		Font = Enum.Font.GothamMedium,
		Parent = searchContainer,
	})
	Theme.Register(searchIcon, "TextColor3", "TertiaryText")

	local searchBox = Elements.Create("TextBox", {
		Name = "SearchInput",
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.new(0, 24, 0, 0),
		BackgroundTransparency = 1,
		PlaceholderText = "Search (Ctrl+K)",
		PlaceholderColor3 = Theme.Get("TertiaryText"),
		Text = "",
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.Subtitle.Size,
		Font = Theme.Typography.Subtitle.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = searchContainer,
	})
	Theme.Register(searchBox, "TextColor3", "Text")
	Theme.Register(searchBox, "PlaceholderColor3", "TertiaryText")

	-- 2. Sidebar (Width: 200px)
	local sidebar = Elements.Create("ScrollingFrame", {
		Name = "Sidebar",
		Size = UDim2.new(0, sidebarWidth, 1, -44 - 24),
		Position = UDim2.new(0, 0, 0, 44),
		BackgroundColor3 = Theme.Get("Sidebar"),
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = main,
	})
	Theme.Register(sidebar, "BackgroundColor3", "Sidebar")
	Elements.Padding(sidebar, { Top = 12, Bottom = 12, Left = 10, Right = 10 })

	local sidebarLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = sidebar,
	})

	local sideDivider = Elements.Hairline(sidebar, "Right")
	Theme.Register(sideDivider, "BackgroundColor3", "Hairline")

	-- 3. Content Pages Area
	local pagesHolder = Elements.Create("Frame", {
		Name = "PagesHolder",
		Size = UDim2.new(1, -sidebarWidth, 1, -44 - 24),
		Position = UDim2.new(0, sidebarWidth, 0, 44),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = main,
	})

	-- 4. Status Bar (Bottom 24px)
	local statusBar = StatusBar.New(main, {
		DefaultText = (options.Title or "vynx") .. "  •  Ready",
	}, library)

	-- Window Object Definition
	local allTabs = {}
	local allSections = {}
	local defaultSection = nil
	local currentTab = nil

	local windowObj = {
		Main = main,
		AllTabs = allTabs,
		AllSections = allSections,
		CurrentTab = nil,
		Launcher = nil,
		StatusBar = statusBar,
	}

	-- Floating Launcher
	local launcher = Launcher.New(gui, windowObj, library)
	windowObj.Launcher = launcher

	function windowObj:AddSection(title)
		local sec = Section.New(sidebar, pagesHolder, title, self, library)
		table.insert(allSections, sec)
		return sec
	end

	-- Backward compatibility: Window:AddTab directly
	function windowObj:AddTab(optionsOrName)
		if not defaultSection then
			defaultSection = self:AddSection("")
		end
		return defaultSection:AddTab(optionsOrName)
	end

	function windowObj:SelectTab(entry)
		if currentTab == entry then return end

		for _, t in ipairs(allTabs) do
			t.Tab:Hide()
			t.Btn.BackgroundTransparency = 1
			t.Label.TextColor3 = Theme.Get("SecondaryText")
			t.Label.Font = Enum.Font.GothamMedium
			if t.Icon and t.Icon:IsA("TextLabel") then
				t.Icon.TextColor3 = Theme.Get("SecondaryText")
			end
		end

		currentTab = entry
		windowObj.CurrentTab = entry
		entry.Tab:Show()
		entry.Btn.BackgroundTransparency = 0
		entry.Btn.BackgroundColor3 = Theme.Get("Accent")
		entry.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
		entry.Label.Font = Enum.Font.GothamBold
		if entry.Icon and entry.Icon:IsA("TextLabel") then
			entry.Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	local themeConn = Theme.Changed:Connect(function(palette)
		if currentTab then
			currentTab.Btn.BackgroundColor3 = palette.Accent
		end
	end)
	maid:Give(themeConn)

	-- Search Query Filtering across tabs and rows
	local function applySearch(query)
		query = string.lower(string.match(query, "^%s*(.-)%s*$") or "")
		if query == "" then
			-- Reset visibility for all rows in all pages
			for _, tabEntry in ipairs(allTabs) do
				local page = tabEntry.Tab.Page
				if page and page.Sections then
					for _, sec in ipairs(page.Sections) do
						for _, f in ipairs(sec.Forms or {}) do
							for _, r in ipairs(f.Rows or {}) do
								r:SetVisible(true)
							end
						end
					end
				end
			end
			return
		end

		local matchingTab = nil
		local currentTabMatches = 0

		for _, tabEntry in ipairs(allTabs) do
			local page = tabEntry.Tab.Page
			local tabHasMatch = false
			if page and page.Sections then
				for _, sec in ipairs(page.Sections) do
					for _, f in ipairs(sec.Forms or {}) do
						for _, r in ipairs(f.Rows or {}) do
							local matches = string.find(r.SearchIndex or "", query, 1, true) ~= nil
							r:SetVisible(matches)
							if matches then
								tabHasMatch = true
								if tabEntry == currentTab then
									currentTabMatches = currentTabMatches + 1
								elseif not matchingTab then
									matchingTab = tabEntry
								end
							end
						end
					end
				end
			end
		end

		-- If current tab has no matches, jump to first matching tab
		if currentTabMatches == 0 and matchingTab then
			windowObj:SelectTab(matchingTab)
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		applySearch(searchBox.Text)
	end)

	-- Ctrl+K search hotkey
	local inputConn = UserInputService.InputBegan:Connect(function(input, processed)
		if not processed then
			if input.KeyCode == toggleKey then
				windowObj:Toggle()
			elseif input.KeyCode == Enum.KeyCode.K and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
				searchBox:CaptureFocus()
			end
		end
	end)
	maid:Give(inputConn)

	-- Window Visibility & Animations
	function windowObj:Toggle(visible)
		if visible ~= nil then
			isVisible = visible
		else
			isVisible = not isVisible
		end

		if isVisible then
			main.Visible = true
			launcher:SetVisible(false)
			Elements.Tween(mainScale, TweenInfo.new(Motion.Duration.Base, Motion.Easing.QuintOut), {
				Scale = 1.0,
			})
		else
			launcher:SetVisible(true)
			local outTween = Elements.Tween(mainScale, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadIn), {
				Scale = 0.95,
			})
			outTween.Completed:Connect(function()
				if not isVisible then
					main.Visible = false
				end
			end)
		end
	end

	function windowObj:Minimize()
		self:Toggle(false)
	end

	function windowObj:ToggleMaximize()
		local camera = workspace.CurrentCamera
		local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)

		if not isMaximized then
			previousSize = main.Size
			previousPosition = main.Position
			isMaximized = true
			local maxW = math.clamp(vp.X - 48, 720, 1100)
			local maxH = math.clamp(vp.Y - 64, 480, 800)
			Elements.Tween(main, TweenInfo.new(Motion.Duration.Base, Motion.Easing.QuintOut), {
				Size = UDim2.fromOffset(maxW, maxH),
				Position = UDim2.fromScale(0.5, 0.5),
			})
		else
			isMaximized = false
			Elements.Tween(main, TweenInfo.new(Motion.Duration.Base, Motion.Easing.QuintOut), {
				Size = previousSize,
				Position = previousPosition,
			})
		end
	end

	-- Traffic-Light Clicks
	closeBtn.MouseButton1Click:Connect(function()
		windowObj:Toggle(false)
	end)

	minBtn.MouseButton1Click:Connect(function()
		windowObj:Minimize()
	end)

	maxBtn.MouseButton1Click:Connect(function()
		windowObj:ToggleMaximize()
	end)

	-- Resize Handle (Bottom-Right)
	if options.Resizable ~= false then
		local resizeHandle = Elements.Create("TextButton", {
			Name = "ResizeHandle",
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -2, 1, -2),
			BackgroundTransparency = 1,
			Text = "◢",
			TextColor3 = Theme.Get("TertiaryText"),
			TextSize = 10,
			Font = Enum.Font.GothamMedium,
			AutoButtonColor = false,
			ZIndex = 50,
			Parent = main,
		})
		Theme.Register(resizeHandle, "TextColor3", "TertiaryText")

		local isResizing = false
		local startPos = Vector2.new()
		local startSize = Vector2.new()

		resizeHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isResizing = true
				startPos = Vector2.new(input.Position.X, input.Position.Y)
				startSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
			end
		end)

		local resizeInputConn = UserInputService.InputChanged:Connect(function(input)
			if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = Vector2.new(input.Position.X - startPos.X, input.Position.Y - startPos.Y)
				local newW = math.clamp(startSize.X + delta.X, 520, 1200)
				local newH = math.clamp(startSize.Y + delta.Y, 360, 900)
				main.Size = UDim2.fromOffset(newW, newH)
			end
		end)
		maid:Give(resizeInputConn)

		local resizeEndConn = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isResizing = false
			end
		end)
		maid:Give(resizeEndConn)
	end

	function windowObj:SetStatus(text)
		statusBar:SetText(text)
	end

	function windowObj:SetWatermark(text)
		statusBar:SetText(text)
	end

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

function Library:SetAccent(accentName)
	Theme.SetAccent(accentName)
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