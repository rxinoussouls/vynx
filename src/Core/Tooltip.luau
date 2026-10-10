local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Elements)
local Theme = require(script.Parent.Theme)

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
