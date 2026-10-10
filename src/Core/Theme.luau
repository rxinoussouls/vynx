--!strict
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
