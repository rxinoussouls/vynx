--!strict
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)

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

	if options.Tooltip then
		Tooltip.Attach(btn, options.Tooltip)
	end

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
