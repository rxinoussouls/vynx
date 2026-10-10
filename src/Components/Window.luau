--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
	local windowSize = options.Size or UDim2.fromOffset(620, 440)
	local tabWidth = options.TabWidth or 130
	local toggleKey = options.Keybind or Enum.KeyCode.RightControl
	local isVisible = true
	local maid = library.Maid

	-- Main window frame perfectly centered using AnchorPoint
	local main = Elements.Create("Frame", {
		Name = "MainWindow",
		Size = windowSize,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Theme.Get("Background"),
		ClipsDescendants = false,
		Parent = gui,
	}) :: Frame
	Elements.Round(main, 8)

	-- Glass Edge (UIStroke with top-to-bottom subtle gradient)
	local mainStroke = Elements.Stroke(main, Theme.Get("Border"), 1, 0)
	Theme.Register(main, "BackgroundColor3", "Background")
	Theme.Register(mainStroke, "Color", "Border")

	local strokeGradient = Elements.Gradient(mainStroke, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 150)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 50)),
	}), 90)

	-- Window Scale for open/close motion
	local mainScale = Elements.Scale(main, 1)

	-- Topbar
	local topbar = Elements.Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		Parent = main,
	}) :: Frame

	-- Drag with screen boundary clamp
	Drag.Make(main, topbar, 0.25, maid)

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
		Position = UDim2.new(0, 0, 0, 38),
		BackgroundColor3 = Theme.Get("Border"),
		BorderSizePixel = 0,
		Parent = main,
	}) :: Frame
	Theme.Register(topDivider, "BackgroundColor3", "Border")

	-- Sidebar (Tab List)
	local sidebar = Elements.Create("ScrollingFrame", {
		Name = "Sidebar",
		Size = UDim2.new(0, tabWidth, 1, -64),
		Position = UDim2.new(0, 0, 0, 39),
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
		Size = UDim2.new(0, 1, 1, -64),
		Position = UDim2.new(0, tabWidth, 0, 39),
		BackgroundColor3 = Theme.Get("Border"),
		BorderSizePixel = 0,
		Parent = main,
	}) :: Frame
	Theme.Register(sideDivider, "BackgroundColor3", "Border")

	-- Pages Container
	local pagesHolder = Elements.Create("Frame", {
		Name = "PagesHolder",
		Size = UDim2.new(1, -tabWidth - 1, 1, -64),
		Position = UDim2.new(0, tabWidth + 1, 0, 39),
		BackgroundTransparency = 1,
		Parent = main,
	}) :: Frame
	Elements.Padding(pagesHolder, 12)

	-- Bottom Status Bar
	local statusBar = Elements.Create("Frame", {
		Name = "StatusBar",
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24),
		BackgroundColor3 = Theme.Get("Secondary"),
		BorderSizePixel = 0,
		Parent = main,
	}) :: Frame
	Elements.Round(statusBar, 4)
	Theme.Register(statusBar, "BackgroundColor3", "Secondary")
	Elements.Padding(statusBar, { Top = 0, Bottom = 0, Left = 12, Right = 12 })

	local statusLeft = Elements.Create("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "vynx  •  ready",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = statusBar,
	}) :: TextLabel
	Theme.Register(statusLeft, "TextColor3", "SubText")

	local statusRight = Elements.Create("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "60 fps • 0 ms",
		TextColor3 = Theme.Get("SubText"),
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = statusBar,
	}) :: TextLabel
	Theme.Register(statusRight, "TextColor3", "SubText")

	-- Live FPS & Ping updates
	local frameCount = 0
	local lastTime = os.clock()
	local fpsConn = RunService.RenderStepped:Connect(function()
		frameCount += 1
		local now = os.clock()
		if now - lastTime >= 1 then
			local fps = math.round(frameCount / (now - lastTime))
			statusRight.Text = string.format("%d fps", fps)
			frameCount = 0
			lastTime = now
		end
	end)
	maid:Give(fpsConn)

	-- Floating Mobile Launcher Button
	local launcher = Elements.Create("TextButton", {
		Name = "VynxMobileLauncher",
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(0, 16, 0.5, -18),
		BackgroundColor3 = Theme.Get("Secondary"),
		Text = "V",
		TextColor3 = Theme.Get("Accent"),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 900,
		Parent = gui,
	}) :: TextButton
	Elements.Round(launcher, 18)
	local launcherStroke = Elements.Stroke(launcher, Theme.Get("Accent"), 1.5, 0)
	Theme.Register(launcher, "BackgroundColor3", "Secondary")
	Theme.Register(launcher, "TextColor3", "Accent")
	Theme.Register(launcherStroke, "Color", "Accent")
	Drag.Make(launcher, launcher, 0.2, maid)

	local tabs = {}
	local currentTab: any = nil

	local windowObj = {
		Main = main,
		Launcher = launcher,
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

			-- Live theme change: update active tab highlight
			local themeConn = Theme.Changed:Connect(function(palette)
				if currentTab == newTab then
					tabBtn.TextColor3 = palette.Accent
				end
			end)
			maid:Give(themeConn)

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

			if isVisible then
				main.Visible = true
				Elements.Tween(mainScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = 1.0,
				})
			else
				local outTween = Elements.Tween(mainScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Scale = 0.95,
				})
				outTween.Completed:Connect(function()
					if not isVisible then
						main.Visible = false
					end
				end)
			end
		end,
	}

	minBtn.MouseButton1Click:Connect(function()
		windowObj:Toggle(false)
	end)

	launcher.MouseButton1Click:Connect(function()
		windowObj:Toggle()
	end)

	local keyConn = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if not processed and input.KeyCode == toggleKey then
			windowObj:Toggle()
		end
	end)
	maid:Give(keyConn)

	return windowObj
end

return Window
