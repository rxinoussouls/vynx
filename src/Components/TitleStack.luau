local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)

local TitleStack = {}

function TitleStack.New(parent, title, subtitle)
	local container = Elements.Create("Frame", {
		Name = "TitleStack",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = container,
	})

	local titleLabel = Elements.Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = title or "",
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.RowTitle.Size,
		Font = Theme.Typography.RowTitle.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		LayoutOrder = 1,
		Parent = container,
	})
	Theme.Register(titleLabel, "TextColor3", "Text")

	local subLabel = nil
	if subtitle and subtitle ~= "" then
		subLabel = Elements.Create("TextLabel", {
			Name = "Subtitle",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text = subtitle,
			TextColor3 = Theme.Get("SecondaryText"),
			TextSize = Theme.Typography.Subtitle.Size,
			Font = Theme.Typography.Subtitle.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			LayoutOrder = 2,
			Parent = container,
		})
		Theme.Register(subLabel, "TextColor3", "SecondaryText")
	end

	return {
		Container = container,
		TitleLabel = titleLabel,
		SubtitleLabel = subLabel,
		SetTitle = function(self, newTitle)
			titleLabel.Text = newTitle
		end,
		SetSubtitle = function(self, newSub)
			if not subLabel and newSub and newSub ~= "" then
				subLabel = Elements.Create("TextLabel", {
					Name = "Subtitle",
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Text = newSub,
					TextColor3 = Theme.Get("SecondaryText"),
					TextSize = Theme.Typography.Subtitle.Size,
					Font = Theme.Typography.Subtitle.Font,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					LayoutOrder = 2,
					Parent = container,
				})
				Theme.Register(subLabel, "TextColor3", "SecondaryText")
			elseif subLabel then
				subLabel.Text = newSub or ""
				subLabel.Visible = (newSub ~= nil and newSub ~= "")
			end
		end,
	}
end

return TitleStack
