local TweenService = game:GetService("TweenService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)

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
