local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)
local Tooltip = require(script.Parent.Parent.Core.Tooltip)

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
