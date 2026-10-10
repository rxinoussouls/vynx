--!strict
local TweenService = game:GetService("TweenService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)

local Notification = {}

local holder: Frame? = nil
local activeQueue = {} :: { Frame }
local MAX_NOTIFICATIONS = 5

function Notification.Init(gui: ScreenGui)
	if holder and holder.Parent then return end

	holder = Elements.Create("Frame", {
		Name = "VynxNotificationHolder",
		Size = UDim2.new(0, 280, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -10),
		BackgroundTransparency = 1,
		ZIndex = 800,
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
	Type: ("Info" | "Success" | "Warn" | "Error")?,
	Duration: number?,
}

function Notification.Show(info: NotifyInfo)
	if not holder then return end

	-- Limit max stacked notifications
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

	-- Wrapper frame for UIListLayout
	local wrapper = Elements.Create("Frame", {
		Name = "ToastWrapper",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent = holder,
	}) :: Frame
	table.insert(activeQueue, wrapper)

	-- Inner toast frame (position can be freely tweened without UIListLayout interference)
	local toast = Elements.Create("Frame", {
		Name = "Toast",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Get("Secondary"),
		Position = UDim2.new(1, 300, 0, 0), -- starts offscreen right
		ZIndex = 801,
		Parent = wrapper,
	}) :: Frame
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
	}) :: TextLabel

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
	}) :: TextLabel
	Theme.Register(contentLabel, "TextColor3", "Text")

	local barBg = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Theme.Get("Surface"),
		LayoutOrder = 3,
		ZIndex = 802,
		Parent = toast,
	}) :: Frame

	local progress = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = typeColor,
		ZIndex = 803,
		Parent = barBg,
	}) :: Frame

	-- Animate In
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

	-- Timer loop with pause on hover
	task.spawn(function()
		while timeLeft > 0 and wrapper.Parent do
			local dt = task.wait(0.05)
			if not isPaused then
				timeLeft -= dt
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
