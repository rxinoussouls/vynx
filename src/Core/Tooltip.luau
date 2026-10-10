--!strict
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Elements)
local Theme = require(script.Parent.Theme)

local Tooltip = {}

local tooltipFrame: Frame? = nil
local tooltipLabel: TextLabel? = nil
local activeTarget: GuiObject? = nil
local hoverTime = 0
local isHovering = false

function Tooltip.Init(gui: ScreenGui)
	if tooltipFrame then return end

	tooltipFrame = Elements.Create("Frame", {
		Name = "VynxTooltip",
		Size = UDim2.new(0, 0, 0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Get("Secondary"),
		Visible = false,
		ZIndex = 200,
		Parent = gui,
	}) :: Frame
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
		ZIndex = 201,
		Parent = tooltipFrame,
	}) :: TextLabel
	Theme.Register(tooltipLabel, "TextColor3", "Text")

	UserInputService.InputChanged:Connect(function(input: InputObject)
		if isHovering and tooltipFrame and tooltipFrame.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
			tooltipFrame.Position = UDim2.fromOffset(input.Position.X + 12, input.Position.Y + 12)
		end
	end)

	RunService.RenderStepped:Connect(function(dt: number)
		if isHovering and activeTarget and not (tooltipFrame and tooltipFrame.Visible) then
			hoverTime += dt
			if hoverTime >= 0.35 and tooltipFrame then
				local mousePos = UserInputService:GetMouseLocation()
				tooltipFrame.Position = UDim2.fromOffset(mousePos.X + 12, mousePos.Y + 12)
				tooltipFrame.Visible = true
			end
		end
	end)
end

function Tooltip.Attach(target: GuiObject, text: string)
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

return Tooltip
