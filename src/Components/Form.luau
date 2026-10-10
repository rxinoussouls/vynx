local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Row = require(script.Parent.Row)

local Form = {}

function Form.New(parent, library)
	local card = Elements.Create("Frame", {
		Name = "FormCard",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Get("FormCard"),
		ClipsDescendants = false,
		Parent = parent,
	})
	Elements.Round(card, 10)
	local stroke = Elements.Stroke(card, Theme.Get("Hairline"), 1, 0)
	Theme.Register(card, "BackgroundColor3", "FormCard")
	Theme.Register(stroke, "Color", "Hairline")

	local cardLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0),
		Parent = card,
	})

	local rows = {}

	local formObj = {
		Frame = card,
		Rows = rows,
		AddRow = function(self, options)
			local r = Row.New(card, options)
			table.insert(rows, r)
			-- Update hairline visibility on last row
			for i, rowItem in ipairs(rows) do
				rowItem:SetHairlineVisible(i < #rows)
			end
			return r
		end,
		AddToggle = function(self, id, options)
			local Toggle = require(script.Parent.Toggle)
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local toggleControl = Toggle.New(r:Right(), id, options, library, true)
			return toggleControl
		end,
		AddSlider = function(self, id, options)
			local Slider = require(script.Parent.Slider)
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			-- Slider takes full right half or custom width
			r.LeftContainer.Size = UDim2.new(0.45, -8, 0, 0)
			r.RightContainer.Size = UDim2.new(0.55, 0, 1, 0)
			local sliderControl = Slider.New(r:Right(), id, options, library.Options, true)
			return sliderControl
		end,
		AddButton = function(self, options)
			local Button = require(script.Parent.Button)
			local r = self:AddRow({
				Title = options.Title or options.Text or "Action",
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text,
			})
			local btnControl = Button.New(r:Right(), options)
			return btnControl
		end,
		AddDropdown = function(self, id, options)
			local Dropdown = require(script.Parent.Dropdown)
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local dropdownControl = Dropdown.New(r:Right(), id, options, library.Options, true)
			return dropdownControl
		end,
		AddColorpicker = function(self, id, options)
			local Colorpicker = require(script.Parent.Colorpicker)
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local cpControl = Colorpicker.New(r:Right(), id, options, library.Options, true)
			return cpControl
		end,
		AddKeybind = function(self, id, options)
			local Keybind = require(script.Parent.Keybind)
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local kbControl = Keybind.New(r:Right(), id, options, library.Options, true)
			return kbControl
		end,
		AddInput = function(self, id, options)
			local Input = require(script.Parent.Input)
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			r.LeftContainer.Size = UDim2.new(0.45, -8, 0, 0)
			r.RightContainer.Size = UDim2.new(0.55, 0, 1, 0)
			local inputControl = Input.New(r:Right(), id, options, library.Options, true)
			return inputControl
		end,
		AddStepper = function(self, id, options)
			local Stepper = require(script.Parent.Stepper)
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			local stepControl = Stepper.New(r:Right(), id, options, library.Options)
			return stepControl
		end,
		AddSegmented = function(self, id, options)
			local Segmented = require(script.Parent.Segmented)
			local r = self:AddRow({
				Title = options.Text or id,
				Subtitle = options.Subtitle,
				SearchIndex = options.SearchIndex or options.Text or id,
			})
			r.LeftContainer.Size = UDim2.new(0.45, -8, 0, 0)
			r.RightContainer.Size = UDim2.new(0.55, 0, 1, 0)
			local segControl = Segmented.New(r:Right(), id, options, library.Options)
			return segControl
		end,
		AddDivider = function(self)
			local r = self:AddRow({})
			r.Frame.Size = UDim2.new(1, 0, 0, 1)
			return r
		end,
		AddLabel = function(self, text, subtitle)
			local r = self:AddRow({
				Title = text,
				Subtitle = subtitle,
				SearchIndex = text,
			})
			return r
		end,
		AddDependencyBox = function(self, parentToggle)
			local depHolder = Elements.Create("Frame", {
				Name = "DependencyHolder",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Visible = parentToggle.Value == true,
				Parent = card,
			})
			local depForm = Form.New(depHolder, library)
			if parentToggle.OnChanged then
				parentToggle:OnChanged(function(val)
					depHolder.Visible = (val == true)
				end)
			else
				local oldCb = parentToggle.Callback
				parentToggle.Callback = function(val)
					depHolder.Visible = (val == true)
					if oldCb then oldCb(val) end
				end
			end
			return depForm
		end,
	}

	return formObj
end

return Form
