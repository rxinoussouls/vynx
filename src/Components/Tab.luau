local Elements = require(script.Parent.Parent.Core.Elements)
local Groupbox = require(script.Parent.Groupbox)

local Tab = {}

function Tab.New(parent, name, library)
	local page = Elements.Create("Frame", {
		Name = name .. "_Page",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local leftColumn = Elements.Create("ScrollingFrame", {
		Name = "LeftColumn",
		Size = UDim2.new(0.5, -6, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = page,
	})

	local leftLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = leftColumn,
	})

	local rightColumn = Elements.Create("ScrollingFrame", {
		Name = "RightColumn",
		Size = UDim2.new(0.5, -6, 1, 0),
		Position = UDim2.new(0.5, 6, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = page,
	})

	local rightLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = rightColumn,
	})

	local tabObj = {
		Name = name,
		Page = page,
		AddLeftGroupbox = function(self, title)
			return Groupbox.New(leftColumn, title, library)
		end,
		AddRightGroupbox = function(self, title)
			return Groupbox.New(rightColumn, title, library)
		end,
		Show = function(self)
			page.Visible = true
		end,
		Hide = function(self)
			page.Visible = false
		end,
	}

	return tabObj
end

return Tab
