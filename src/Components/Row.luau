local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local TitleStack = require(script.Parent.TitleStack)

local Row = {}

function Row.New(parent, options)
	options = options or {}
	local isTouch = UserInputService.TouchEnabled
	local minHeight = isTouch and 52 or 44

	local frame = Elements.Create("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, minHeight),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent = parent,
	})

	Elements.Padding(frame, { Top = 10, Bottom = 10, Left = 12, Right = 12 })

	local leftContainer = Elements.Create("Frame", {
		Name = "Left",
		Size = UDim2.new(0.60, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	local titleStack = nil
	if options.Title then
		titleStack = TitleStack.New(leftContainer, options.Title, options.Subtitle)
	end

	local rightContainer = Elements.Create("Frame", {
		Name = "Right",
		Size = UDim2.new(0.40, 0, 1, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	local rightLayout = Elements.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = rightContainer,
	})

	local hairline = Elements.Hairline(frame, 12)
	Theme.Register(hairline, "BackgroundColor3", "Hairline")

	local searchIndex = string.lower(options.SearchIndex or options.Title or "")

	local rowObj = {
		Frame = frame,
		LeftContainer = leftContainer,
		RightContainer = rightContainer,
		TitleStack = titleStack,
		Hairline = hairline,
		SearchIndex = searchIndex,
		Left = function(self)
			return leftContainer
		end,
		Right = function(self)
			return rightContainer
		end,
		SetTitle = function(self, title, subtitle)
			if not self.TitleStack then
				self.TitleStack = TitleStack.New(leftContainer, title, subtitle)
			else
				self.TitleStack:SetTitle(title)
				if subtitle ~= nil then
					self.TitleStack:SetSubtitle(subtitle)
				end
			end
			self.SearchIndex = string.lower(title or "")
		end,
		SetHairlineVisible = function(self, visible)
			hairline.Visible = visible
		end,
		SetVisible = function(self, visible)
			frame.Visible = visible
		end,
	}

	return rowObj
end

return Row
