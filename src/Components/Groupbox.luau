--!strict
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)

local Button = require(script.Parent.Button)
local Toggle = require(script.Parent.Toggle)
local Slider = require(script.Parent.Slider)
local Dropdown = require(script.Parent.Dropdown)
local Colorpicker = require(script.Parent.Colorpicker)
local Keybind = require(script.Parent.Keybind)
local Input = require(script.Parent.Input)

local Groupbox = {}

function Groupbox.New(parent: GuiObject, title: string, library: any)
	local isCollapsed = false

	local box = Elements.Create("Frame", {
		Name = title .. "_Groupbox",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Get("Secondary"),
		ZIndex = 2,
		Parent = parent,
	}) :: Frame
	Elements.Round(box, 6)
	local boxStroke = Elements.Stroke(box, Theme.Get("Border"), 1, 0)
	Theme.Register(box, "BackgroundColor3", "Secondary")
	Theme.Register(boxStroke, "Color", "Border")
	Elements.Padding(box, { Top = 10, Bottom = 10, Left = 12, Right = 12 })

	-- UIListLayout for the box so header and container do not overlap!
	local boxLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = box,
	})

	-- Section Header Row
	local headerRow = Elements.Create("Frame", {
		Name = "HeaderRow",
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		ZIndex = 3,
		Parent = box,
	}) :: Frame

	local header = Elements.Create("TextLabel", {
		Size = UDim2.new(1, -24, 1, 0),
		BackgroundTransparency = 1,
		Text = string.upper(title),
		TextColor3 = Theme.Get("Accent"),
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = headerRow,
	}) :: TextLabel
	Theme.Register(header, "TextColor3", "Accent")

	-- Collapse button
	local collapseBtn = Elements.Create("TextButton", {
		Size = UDim2.new(0, 16, 0, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Text = "-",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		ZIndex = 3,
		Parent = headerRow,
	}) :: TextButton
	Theme.Register(collapseBtn, "TextColor3", "SubText")

	-- Children container
	local container = Elements.Create("Frame", {
		Name = "Container",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		ZIndex = 3,
		Parent = box,
	}) :: Frame

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = container,
	})

	collapseBtn.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed
		collapseBtn.Text = isCollapsed and "+" or "-"
		container.Visible = not isCollapsed
	end)

	local boxObj = {
		Frame = box,
		Container = container,
		AddToggle = function(self: any, id: string, options: any)
			return Toggle.New(container, id, options, library)
		end,
		AddButton = function(self: any, options: any)
			return Button.New(container, options)
		end,
		AddSlider = function(self: any, id: string, options: any)
			return Slider.New(container, id, options, library.Options)
		end,
		AddDropdown = function(self: any, id: string, options: any)
			return Dropdown.New(container, id, options, library.Options)
		end,
		AddColorpicker = function(self: any, id: string, options: any)
			return Colorpicker.New(container, id, options, library.Options)
		end,
		AddKeybind = function(self: any, id: string, options: any)
			return Keybind.New(container, id, options, library.Options)
		end,
		AddInput = function(self: any, id: string, options: any)
			return Input.New(container, id, options, library.Options)
		end,
		AddDivider = function(self: any)
			local div = Elements.Create("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Get("Border"),
				BorderSizePixel = 0,
				Parent = container,
			})
			Theme.Register(div, "BackgroundColor3", "Border")
			return div
		end,
		AddLabel = function(self: any, text: string)
			local lbl = Elements.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Get("Text"),
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})
			Theme.Register(lbl, "TextColor3", "Text")
			return lbl
		end,
		AddDependencyBox = function(self: any, parentToggle: any)
			local depContainer = Elements.Create("Frame", {
				Name = "DependencyBox",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Visible = parentToggle.Value == true,
				Parent = container,
			}) :: Frame
			Elements.Padding(depContainer, { Top = 0, Bottom = 0, Left = 12, Right = 0 })

			local depLayout = Elements.Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
				Parent = depContainer,
			})

			-- Vertical left indicator bar
			local bar = Elements.Create("Frame", {
				Size = UDim2.new(0, 2, 1, 0),
				Position = UDim2.new(0, -6, 0, 0),
				BackgroundColor3 = Theme.Get("Accent"),
				BorderSizePixel = 0,
				Parent = depContainer,
			})
			Theme.Register(bar, "BackgroundColor3", "Accent")

			local oldCb = parentToggle.Callback
			parentToggle.Callback = function(val: boolean)
				depContainer.Visible = val
				if oldCb then oldCb(val) end
			end

			local depObj = Groupbox.New(depContainer, "", library)
			depObj.Frame.BackgroundTransparency = 1
			depObj.Frame.BorderSizePixel = 0
			return depObj
		end,
	}

	return boxObj
end

return Groupbox
