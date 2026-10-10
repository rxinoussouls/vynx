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
	local originalText = options.Text or "Button"
	local waitingConfirm = false
	local confirmThread: thread? = nil

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
	}) :: TextButton

	Elements.Round(btn, 6)
	local stroke = Elements.Stroke(btn, Theme.Get("Border"), 1, 0)
	Theme.Register(btn, "BackgroundColor3", "Surface")
	Theme.Register(btn, "TextColor3", "Text")
	Theme.Register(stroke, "Color", "Border")

	if options.Tooltip then
		Tooltip.Attach(btn, options.Tooltip)
	end

	-- Smooth scale bounce via UIScale without affecting neighboring items in layout
	local uiScale = Elements.Scale(btn, 1)

	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	btn.MouseEnter:Connect(function()
		Elements.Tween(stroke, tweenInfo, { Color = Theme.Get("Accent") })
	end)

	btn.MouseLeave:Connect(function()
		Elements.Tween(stroke, tweenInfo, { Color = Theme.Get("Border") })
	end)

	btn.MouseButton1Click:Connect(function()
		-- UIScale bounce animation
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
