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
