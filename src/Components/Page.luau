local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local PageSection = require(script.Parent.PageSection)
local Form = require(script.Parent.Form)

local Page = {}

function Page.New(parent, title, library)
	local scrollFrame = Elements.Create("ScrollingFrame", {
		Name = (title or "Page") .. "_Scroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Get("ControlFill"),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ClipsDescendants = true,
		Parent = parent,
	})

	Elements.Padding(scrollFrame, { Top = 20, Bottom = 24, Left = 24, Right = 24 })

	local layout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 18),
		Parent = scrollFrame,
	})

	-- Large Page Title at top of each page
	local titleLabel = Elements.Create("TextLabel", {
		Name = "LargePageTitle",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Text = title or "Settings",
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.PageTitle.Size,
		Font = Theme.Typography.PageTitle.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		Parent = scrollFrame,
	})
	Theme.Register(titleLabel, "TextColor3", "Text")

	local sections = {}

	local pageObj = {
		Frame = scrollFrame,
		Title = title,
		Sections = sections,
		AddPageSection = function(self, options)
			if typeof(options) == "string" then
				options = { Title = options }
			end
			local sec = PageSection.New(scrollFrame, options, library)
			sec.Frame.LayoutOrder = #sections + 2
			table.insert(sections, sec)
			return sec
		end,
		AddForm = function(self)
			local sec = self:AddPageSection({})
			return sec:AddForm()
		end,
		Show = function(self)
			scrollFrame.Visible = true
		end,
		Hide = function(self)
			scrollFrame.Visible = false
		end,
	}

	return pageObj
end

return Page
