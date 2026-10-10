--!strict
local UserInputService = game:GetService("UserInputService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Drag = require(script.Parent.Parent.Core.Drag)
local Tab = require(script.Parent.Tab)

local Window = {}

export type WindowOptions = {
	Title: string,
	SubTitle: string?,
	Size: UDim2?,
	TabWidth: number?,
	Keybind: Enum.KeyCode?,
}

function Window.New(gui: ScreenGui, options: WindowOptions, library: any)
	local windowSize = options.Size or UDim2.fromOffset(600, 420)
	local tabWidth = options.TabWidth or 130
	local toggleKey = options.Keybind or Enum.KeyCode.RightControl
	local isVisible = true

	local main = Elements.Create("Frame", {
		Name = "MainWindow",
		Size = windowSize,
		Position = UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2),
		BackgroundColor3 = Theme.Get("Background"),
		ClipsDescendants = false,
		Parent = gui,
	}) :: Frame
	Elements.Round(main, 8)
	local mainStroke = Elements.Stroke(main, Theme.Get("Border"), 1, 0)
	Theme.Register(main, "BackgroundColor3", "Background")
	Theme.Register(mainStroke, "Color", "Border")

	-- Topbar
	local topbar = Elements.Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = main,
	}) :: Frame

	-- Drag
	Drag.Make(main, topbar, 0.25)

	-- Title and SubTitle
	local titleLabel = Elements.Create("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "vynx",
		TextColor3 = Theme.Get("Text"),
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	}) :: TextLabel
	Theme.Register(titleLabel, "TextColor3", "Text")

	if options.SubTitle then
		local subLabel = Elements.Create("TextLabel", {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Position = UDim2.new(0, 14, 0, 0),
			BackgroundTransparency = 1,
			Text = " / " .. options.SubTitle,
			TextColor3 = Theme.Get("SubText"),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = topbar,
		}) :: TextLabel
		Theme.Register(subLabel, "TextColor3", "SubText")
		titleLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			subLabel.Position = UDim2.new(0, 14 + titleLabel.AbsoluteSize.X + 4, 0, 0)
		end)
	end

	-- Control Buttons
	local minBtn = Elements.Create("TextButton", {
		Size = UDim2.new(0, 24, 0, 24),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Text = "-",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		Parent = topbar,
	}) :: TextButton

	-- Topbar Divider
	local topDivider = Elements.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = Theme.Get("Border"),
		BorderSizePixel = 0,
		Parent = main,
	}) :: Frame
	Theme.Register(topDivider, "BackgroundColor3", "Border")

	-- Sidebar (Tab List)
	local sidebar = Elements.Create("ScrollingFrame", {
		Name = "Sidebar",
		Size = UDim2.new(0, tabWidth, 1, -37),
		Position = UDim2.new(0, 0, 0, 37),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = main,
	}) :: ScrollingFrame
	Elements.Padding(sidebar, { Top = 10, Bottom = 10, Left = 8, Right = 8 })

	local tabListLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = sidebar,
	})

	-- Sidebar Divider
	local sideDivider = Elements.Create("Frame", {
		Size = UDim2.new(0, 1, 1, -37),
		Position = UDim2.new(0, tabWidth, 0, 37),
		BackgroundColor3 = Theme.Get("Border"),
		BorderSizePixel = 0,
		Parent = main,
	}) :: Frame
	Theme.Register(sideDivider, "BackgroundColor3", "Border")

	-- Pages Container
	local pagesHolder = Elements.Create("Frame", {
		Name = "PagesHolder",
		Size = UDim2.new(1, -tabWidth - 1, 1, -37),
		Position = UDim2.new(0, tabWidth + 1, 0, 37),
		BackgroundTransparency = 1,
		Parent = main,
	}) :: Frame
	Elements.Padding(pagesHolder, 12)

	local tabs = {}
	local currentTab: any = nil

	local windowObj = {
		Main = main,
		AddTab = function(self: any, name: string)
			local newTab = Tab.New(pagesHolder, name, library)

			local tabBtn = Elements.Create("TextButton", {
				Name = name .. "_TabBtn",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = Theme.Get("Surface"),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.Get("SubText"),
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				AutoButtonColor = false,
				Parent = sidebar,
			}) :: TextButton
			Elements.Round(tabBtn, 5)

			local function selectTab()
				if currentTab == newTab then return end
				for _, t in ipairs(tabs) do
					t.TabObj:Hide()
					Elements.Tween(t.Btn, TweenInfo.new(0.15), {
						BackgroundTransparency = 1,
						TextColor3 = Theme.Get("SubText"),
					})
				end
				currentTab = newTab
				newTab:Show()
				Elements.Tween(tabBtn, TweenInfo.new(0.15), {
					BackgroundTransparency = 0,
					TextColor3 = Theme.Get("Accent"),
				})
			end

			tabBtn.MouseButton1Click:Connect(selectTab)
			table.insert(tabs, { Name = name, TabObj = newTab, Btn = tabBtn })

			if #tabs == 1 then
				selectTab()
			end

			return newTab
		end,
		Toggle = function(self: any, visible: boolean?)
			if visible ~= nil then
				isVisible = visible
			else
				isVisible = not isVisible
			end
			main.Visible = isVisible
		end,
	}

	minBtn.MouseButton1Click:Connect(function()
		windowObj:Toggle(false)
	end)

	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if not processed and input.KeyCode == toggleKey then
			windowObj:Toggle()
		end
	end)

	return windowObj
end

return Window
