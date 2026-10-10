local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Icons = require(script.Parent.Parent.Core.Icons)
local Tab = require(script.Parent.Tab)

local Section = {}

function Section.New(sidebarContainer, pagesHolder, sectionTitle, windowObj, library)
	local sectionFrame = Elements.Create("Frame", {
		Name = (sectionTitle ~= "" and sectionTitle or "Section") .. "_Sidebar",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = sidebarContainer,
	})

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = sectionFrame,
	})

	if sectionTitle and sectionTitle ~= "" then
		local headerLabel = Elements.Create("TextLabel", {
			Name = "SectionHeader",
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Text = string.upper(sectionTitle),
			TextColor3 = Theme.Get("SecondaryText"),
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			Parent = sectionFrame,
		})
		Elements.Padding(headerLabel, { Top = 4, Bottom = 2, Left = 10, Right = 10 })
		Theme.Register(headerLabel, "TextColor3", "SecondaryText")
	end

	local tabsContainer = Elements.Create("Frame", {
		Name = "TabsContainer",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = sectionFrame,
	})

	local tabsLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
		Parent = tabsContainer,
	})

	local sectionObj = {
		Frame = sectionFrame,
		Title = sectionTitle,
		AddTab = function(self, options)
			if typeof(options) == "string" then
				options = { Title = options }
			end
			local title = options.Title or "Tab"
			local iconName = options.Icon
			local isSelected = options.Selected or false

			local tabObj = Tab.New(pagesHolder, title, library)

			local btn = Elements.Create("TextButton", {
				Name = title .. "_TabBtn",
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = Theme.Get("Accent"),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = tabsContainer,
			})
			Elements.Round(btn, 6)
			Elements.Padding(btn, { Top = 0, Bottom = 0, Left = 10, Right = 10 })

			local btnLayout = Elements.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8),
				Parent = btn,
			})

			local iconObj = nil
			if iconName then
				iconObj = Icons.Render(iconName, btn, 16, Theme.Get("SecondaryText"))
			end

			local textLabel = Elements.Create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, iconObj and -24 or 0, 1, 0),
				BackgroundTransparency = 1,
				Text = title,
				TextColor3 = Theme.Get("SecondaryText"),
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = btn,
			})

			local entry = {
				Title = title,
				Tab = tabObj,
				Btn = btn,
				Icon = iconObj,
				Label = textLabel,
			}

			local function selectTab()
				windowObj:SelectTab(entry)
			end

			btn.MouseButton1Click:Connect(selectTab)
			table.insert(windowObj.AllTabs, entry)

			if isSelected or #windowObj.AllTabs == 1 then
				selectTab()
			end

			return tabObj
		end,
	}

	return sectionObj
end

return Section
