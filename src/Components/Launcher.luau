local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)
local Drag = require(script.Parent.Parent.Core.Drag)

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
