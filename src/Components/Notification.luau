--!strict
local TweenService = game:GetService("TweenService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)

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
