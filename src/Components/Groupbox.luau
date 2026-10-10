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

function Groupbox.New(parent, title, library)
	local isCollapsed = false

	local box = Elements.Create("Frame", {
		Name = title .. "_Groupbox",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Get("Secondary"),
		ZIndex = 2,
		Parent = parent,
	})
	Elements.Round(box, 6)
	local boxStroke = Elements.Stroke(box, Theme.Get("Border"), 1, 0)
	Theme.Register(box, "BackgroundColor3", "Secondary")
	Theme.Register(boxStroke, "Color", "Border")
	Elements.Padding(box, { Top = 10, Bottom = 10, Left = 12, Right = 12 })

	local boxLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = box,
	})

	local headerRow = Elements.Create("Frame", {
		Name = "HeaderRow",
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		ZIndex = 3,
		Parent = box,
	})

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
	})
	Theme.Register(header, "TextColor3", "Accent")

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
	})
	Theme.Register(collapseBtn, "TextColor3", "SubText")

	local container = Elements.Create("Frame", {
		Name = "Container",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		ZIndex = 3,
		Parent = box,
	})

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
		AddToggle = function(self, id, options)
			return Toggle.New(container, id, options, library)
		end,
		AddButton = function(self, options)
			return Button.New(container, options)
		end,
		AddSlider = function(self, id, options)
			return Slider.New(container, id, options, library.Options)
		end,
		AddDropdown = function(self, id, options)
			return Dropdown.New(container, id, options, library.Options)
		end,
		AddColorpicker = function(self, id, options)
			return Colorpicker.New(container, id, options, library.Options)
		end,
		AddKeybind = function(self, id, options)
			return Keybind.New(container, id, options, library.Options)
		end,
		AddInput = function(self, id, options)
			return Input.New(container, id, options, library.Options)
		end,
		AddDivider = function(self)
			local div = Elements.Create("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Get("Border"),
				BorderSizePixel = 0,
				Parent = container,
			})
			Theme.Register(div, "BackgroundColor3", "Border")
			return div
		end,
		AddLabel = function(self, text)
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
		AddDependencyBox = function(self, parentToggle)
			local depContainer = Elements.Create("Frame", {
				Name = "DependencyBox",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Visible = parentToggle.Value == true,
				Parent = container,
			})
			Elements.Padding(depContainer, { Top = 0, Bottom = 0, Left = 12, Right = 0 })

			local depLayout = Elements.Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
				Parent = depContainer,
			})

			local bar = Elements.Create("Frame", {
				Size = UDim2.new(0, 2, 1, 0),
				Position = UDim2.new(0, -6, 0, 0),
				BackgroundColor3 = Theme.Get("Accent"),
				BorderSizePixel = 0,
				Parent = depContainer,
			})
			Theme.Register(bar, "BackgroundColor3", "Accent")

			local oldCb = parentToggle.Callback
			parentToggle.Callback = function(val)
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
