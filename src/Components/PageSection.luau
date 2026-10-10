local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Form = require(script.Parent.Form)

local PageSection = {}

function PageSection.New(parent, options, library)
	options = options or {}
	local title = options.Title or ""
	local subtitle = options.Subtitle

	local sectionFrame = Elements.Create("Frame", {
		Name = (title ~= "" and title or "PageSection") .. "_Container",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = sectionFrame,
	})

	if title and title ~= "" then
		local headerHolder = Elements.Create("Frame", {
			Name = "HeaderHolder",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = sectionFrame,
		})
		Elements.Padding(headerHolder, { Top = 0, Bottom = 2, Left = 4, Right = 4 })

		local headerLayout = Elements.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
			Parent = headerHolder,
		})

		local headingLabel = Elements.Create("TextLabel", {
			Name = "SectionHeading",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Theme.Get("SecondaryText"),
			TextSize = Theme.Typography.SectionHeading.Size,
			Font = Theme.Typography.SectionHeading.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			Parent = headerHolder,
		})
		Theme.Register(headingLabel, "TextColor3", "SecondaryText")

		if subtitle and subtitle ~= "" then
			local subLabel = Elements.Create("TextLabel", {
				Name = "SectionSubtitle",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text = subtitle,
				TextColor3 = Theme.Get("TertiaryText"),
				TextSize = Theme.Typography.Subtitle.Size,
				Font = Theme.Typography.Subtitle.Font,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				LayoutOrder = 2,
				Parent = headerHolder,
			})
			Theme.Register(subLabel, "TextColor3", "TertiaryText")
		end
	end

	local formHolder = Elements.Create("Frame", {
		Name = "FormHolder",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = sectionFrame,
	})

	local formListLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = formHolder,
	})

	local forms = {}
	local defaultForm = nil

	local sectionObj = {
		Frame = sectionFrame,
		Forms = forms,
		AddForm = function(self)
			local f = Form.New(formHolder, library)
			table.insert(forms, f)
			if not defaultForm then defaultForm = f end
			return f
		end,
		-- Direct shortcuts delegate to default form
		AddToggle = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddToggle(id, opts)
		end,
		AddSlider = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddSlider(id, opts)
		end,
		AddButton = function(self, opts)
			local f = defaultForm or self:AddForm()
			return f:AddButton(opts)
		end,
		AddDropdown = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddDropdown(id, opts)
		end,
		AddColorpicker = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddColorpicker(id, opts)
		end,
		AddKeybind = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddKeybind(id, opts)
		end,
		AddInput = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddInput(id, opts)
		end,
		AddStepper = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddStepper(id, opts)
		end,
		AddSegmented = function(self, id, opts)
			local f = defaultForm or self:AddForm()
			return f:AddSegmented(id, opts)
		end,
		AddDivider = function(self)
			local f = defaultForm or self:AddForm()
			return f:AddDivider()
		end,
		AddLabel = function(self, text, sub)
			local f = defaultForm or self:AddForm()
			return f:AddLabel(text, sub)
		end,
		AddDependencyBox = function(self, toggle)
			local f = defaultForm or self:AddForm()
			return f:AddDependencyBox(toggle)
		end,
	}

	return sectionObj
end

return PageSection
