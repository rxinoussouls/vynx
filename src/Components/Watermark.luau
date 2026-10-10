--!strict
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Drag = require(script.Parent.Parent.Core.Drag)

local Watermark = {}

function Watermark.New(gui: ScreenGui, defaultText: string?)
	local frame = Elements.Create("Frame", {
		Name = "VynxWatermark",
		Size = UDim2.new(0, 0, 0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = Theme.Get("Secondary"),
		ZIndex = 90,
		Parent = gui,
	}) :: Frame
	Elements.Round(frame, 6)
	local stroke = Elements.Stroke(frame, Theme.Get("Border"), 1, 0)
	Theme.Register(frame, "BackgroundColor3", "Secondary")
	Theme.Register(stroke, "Color", "Border")
	Elements.Padding(frame, { Top = 4, Bottom = 4, Left = 10, Right = 10 })

	-- Accent Dot
	local dot = Elements.Create("Frame", {
		Size = UDim2.new(0, 6, 0, 6),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Theme.Get("Accent"),
		ZIndex = 91,
		Parent = frame,
	}) :: Frame
	Elements.Round(dot, 3)
	Theme.Register(dot, "BackgroundColor3", "Accent")

	local label = Elements.Create("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = defaultText or "vynx",
		TextColor3 = Theme.Get("Text"),
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		ZIndex = 91,
		Parent = frame,
	}) :: TextLabel
	Theme.Register(label, "TextColor3", "Text")

	Drag.Make(frame, frame, 0.2)

	local watermarkObj = {
		Frame = frame,
		SetText = function(self: any, text: string)
			label.Text = text
		end,
		SetVisible = function(self: any, visible: boolean)
			frame.Visible = visible
		end,
	}

	return watermarkObj
end

return Watermark
