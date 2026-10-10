local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)
local Motion = require(script.Parent.Parent.Core.Motion)
local Drag = require(script.Parent.Parent.Core.Drag)
local Section = require(script.Parent.Section)
local Tab = require(script.Parent.Tab)
local StatusBar = require(script.Parent.StatusBar)
local Launcher = require(script.Parent.Launcher)

local Window = {}

function Window.New(gui, options, library)
	options = options or {}
	local baseSize = options.Size or UDim2.fromOffset(720, 480)
	local sidebarWidth = options.SidebarWidth or 200
	local toggleKey = options.Keybind or Enum.KeyCode.RightControl
	local isVisible = true
	local isMaximized = false
	local previousSize = baseSize
	local previousPosition = UDim2.fromScale(0.5, 0.5)
	local maid = library.Maid

	if options.Theme then
		Theme.SetTheme(options.Theme)
	end
	if options.Accent then
		Theme.SetAccent(options.Accent)
	end

	-- Root Window Frame
	local main = Elements.Create("Frame", {
		Name = "MainWindow",
		Size = baseSize,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Theme.Get("Window"),
		ClipsDescendants = false,
		Parent = gui,
	})
	Elements.Round(main, 12)

	local mainStroke = Elements.Stroke(main, Theme.Get("WindowStroke"), 1, 0)
	Theme.Register(main, "BackgroundColor3", "Window")
	Theme.Register(mainStroke, "Color", "WindowStroke")

	-- Soft 3-layer drop shadow
	if options.Dropshadow ~= false then
		Elements.Shadow(main, 3, 12, 0.55)
	end

	local mainScale = Elements.Scale(main, 1)

	-- Responsive Auto-Scale for small screens & mobile
	local function updateResponsiveScale()
		local camera = workspace.CurrentCamera
		if camera then
			local vp = camera.ViewportSize
			local targetW = baseSize.X.Offset
			if vp.X < targetW + 40 then
				local s = math.clamp((vp.X - 32) / targetW, 0.55, 1.0)
				mainScale.Scale = s
			else
				mainScale.Scale = 1.0
			end
		end
	end
	updateResponsiveScale()

	local cameraConn = workspace.CurrentCamera and workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
	if cameraConn then maid:Give(cameraConn) end

	-- Window Shell Containers
	-- 1. Topbar (macOS Sequoia Titlebar, height 44px)
	local topbar = Elements.Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Parent = main,
	})

	Drag.Make(main, topbar, 0.25, maid)

	local topDivider = Elements.Hairline(topbar, "Bottom")
	Theme.Register(topDivider, "BackgroundColor3", "Hairline")

	-- Traffic-Light Buttons (Left)
	local trafficContainer = Elements.Create("Frame", {
		Name = "TrafficLights",
		Size = UDim2.fromOffset(64, 16),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = topbar,
	})

	local trafficLayout = Elements.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = trafficContainer,
	})

	local function makeTrafficButton(name, color, symbol, order)
		local btn = Elements.Create("TextButton", {
			Name = name,
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = color,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = order,
			Parent = trafficContainer,
		})
		Elements.Round(btn, 6)

		local glyph = Elements.Create("TextLabel", {
			Name = "Glyph",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = symbol,
			TextColor3 = Color3.fromRGB(40, 20, 20),
			TextSize = 9,
			Font = Enum.Font.GothamBold,
			Visible = false,
			Parent = btn,
		})

		return btn, glyph
	end

	local closeBtn, closeGlyph = makeTrafficButton("CloseBtn", Color3.fromRGB(255, 95, 87), "✕", 1)
	local minBtn, minGlyph = makeTrafficButton("MinBtn", Color3.fromRGB(254, 188, 46), "−", 2)
	local maxBtn, maxGlyph = makeTrafficButton("MaxBtn", Color3.fromRGB(40, 200, 64), "+", 3)

	-- Hover reveals traffic-light glyphs
	local function setGlyphsVisible(vis)
		closeGlyph.Visible = vis
		minGlyph.Visible = vis
		maxGlyph.Visible = vis
	end

	trafficContainer.MouseEnter:Connect(function() setGlyphsVisible(true) end)
	trafficContainer.MouseLeave:Connect(function() setGlyphsVisible(false) end)

	-- Title in Topbar (Subtle macOS style)
	local windowTitleLabel = Elements.Create("TextLabel", {
		Name = "WindowTitle",
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0, 92, 0, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "Settings",
		TextColor3 = Theme.Get("SecondaryText"),
		TextSize = Theme.Typography.SectionHeading.Size,
		Font = Theme.Typography.SectionHeading.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	})
	Theme.Register(windowTitleLabel, "TextColor3", "SecondaryText")

	-- Search Field (macOS Search Bar on Right)
	local searchContainer = Elements.Create("Frame", {
		Name = "SearchField",
		Size = UDim2.new(0, 180, 0, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		BackgroundColor3 = Theme.Get("ControlFill"),
		Parent = topbar,
	})
	Elements.Round(searchContainer, 6)
	local searchStroke = Elements.Stroke(searchContainer, Theme.Get("Hairline"), 1, 0)
	Theme.Register(searchContainer, "BackgroundColor3", "ControlFill")
	Theme.Register(searchStroke, "Color", "Hairline")

	local searchIcon = Elements.Create("TextLabel", {
		Name = "SearchIcon",
		Size = UDim2.fromOffset(24, 28),
		BackgroundTransparency = 1,
		Text = "⌕",
		TextColor3 = Theme.Get("TertiaryText"),
		TextSize = 15,
		Font = Enum.Font.GothamMedium,
		Parent = searchContainer,
	})
	Theme.Register(searchIcon, "TextColor3", "TertiaryText")

	local searchBox = Elements.Create("TextBox", {
		Name = "SearchInput",
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.new(0, 24, 0, 0),
		BackgroundTransparency = 1,
		PlaceholderText = "Search (Ctrl+K)",
		PlaceholderColor3 = Theme.Get("TertiaryText"),
		Text = "",
		TextColor3 = Theme.Get("Text"),
		TextSize = Theme.Typography.Subtitle.Size,
		Font = Theme.Typography.Subtitle.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = searchContainer,
	})
	Theme.Register(searchBox, "TextColor3", "Text")
	Theme.Register(searchBox, "PlaceholderColor3", "TertiaryText")

	-- 2. Sidebar (Width: 200px)
	local sidebar = Elements.Create("ScrollingFrame", {
		Name = "Sidebar",
		Size = UDim2.new(0, sidebarWidth, 1, -44 - 24),
		Position = UDim2.new(0, 0, 0, 44),
		BackgroundColor3 = Theme.Get("Sidebar"),
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = main,
	})
	Theme.Register(sidebar, "BackgroundColor3", "Sidebar")
	Elements.Padding(sidebar, { Top = 12, Bottom = 12, Left = 10, Right = 10 })

	local sidebarLayout = Elements.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = sidebar,
	})

	local sideDivider = Elements.Hairline(sidebar, "Right")
	Theme.Register(sideDivider, "BackgroundColor3", "Hairline")

	-- 3. Content Pages Area
	local pagesHolder = Elements.Create("Frame", {
		Name = "PagesHolder",
		Size = UDim2.new(1, -sidebarWidth, 1, -44 - 24),
		Position = UDim2.new(0, sidebarWidth, 0, 44),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = main,
	})

	-- 4. Status Bar (Bottom 24px)
	local statusBar = StatusBar.New(main, {
		DefaultText = (options.Title or "vynx") .. "  •  Ready",
	}, library)

	-- Window Object Definition
	local allTabs = {}
	local allSections = {}
	local defaultSection = nil
	local currentTab = nil

	local windowObj = {
		Main = main,
		AllTabs = allTabs,
		AllSections = allSections,
		CurrentTab = nil,
		Launcher = nil,
		StatusBar = statusBar,
	}

	-- Floating Launcher
	local launcher = Launcher.New(gui, windowObj, library)
	windowObj.Launcher = launcher

	function windowObj:AddSection(title)
		local sec = Section.New(sidebar, pagesHolder, title, self, library)
		table.insert(allSections, sec)
		return sec
	end

	-- Backward compatibility: Window:AddTab directly
	function windowObj:AddTab(optionsOrName)
		if not defaultSection then
			defaultSection = self:AddSection("")
		end
		return defaultSection:AddTab(optionsOrName)
	end

	function windowObj:SelectTab(entry)
		if currentTab == entry then return end

		for _, t in ipairs(allTabs) do
			t.Tab:Hide()
			t.Btn.BackgroundTransparency = 1
			t.Label.TextColor3 = Theme.Get("SecondaryText")
			t.Label.Font = Enum.Font.GothamMedium
			if t.Icon and t.Icon:IsA("TextLabel") then
				t.Icon.TextColor3 = Theme.Get("SecondaryText")
			end
		end

		currentTab = entry
		windowObj.CurrentTab = entry
		entry.Tab:Show()
		entry.Btn.BackgroundTransparency = 0
		entry.Btn.BackgroundColor3 = Theme.Get("Accent")
		entry.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
		entry.Label.Font = Enum.Font.GothamBold
		if entry.Icon and entry.Icon:IsA("TextLabel") then
			entry.Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	local themeConn = Theme.Changed:Connect(function(palette)
		if currentTab then
			currentTab.Btn.BackgroundColor3 = palette.Accent
		end
	end)
	maid:Give(themeConn)

	-- Search Query Filtering across tabs and rows
	local function applySearch(query)
		query = string.lower(string.match(query, "^%s*(.-)%s*$") or "")
		if query == "" then
			-- Reset visibility for all rows in all pages
			for _, tabEntry in ipairs(allTabs) do
				local page = tabEntry.Tab.Page
				if page and page.Sections then
					for _, sec in ipairs(page.Sections) do
						for _, f in ipairs(sec.Forms or {}) do
							for _, r in ipairs(f.Rows or {}) do
								r:SetVisible(true)
							end
						end
					end
				end
			end
			return
		end

		local matchingTab = nil
		local currentTabMatches = 0

		for _, tabEntry in ipairs(allTabs) do
			local page = tabEntry.Tab.Page
			local tabHasMatch = false
			if page and page.Sections then
				for _, sec in ipairs(page.Sections) do
					for _, f in ipairs(sec.Forms or {}) do
						for _, r in ipairs(f.Rows or {}) do
							local matches = string.find(r.SearchIndex or "", query, 1, true) ~= nil
							r:SetVisible(matches)
							if matches then
								tabHasMatch = true
								if tabEntry == currentTab then
									currentTabMatches = currentTabMatches + 1
								elseif not matchingTab then
									matchingTab = tabEntry
								end
							end
						end
					end
				end
			end
		end

		-- If current tab has no matches, jump to first matching tab
		if currentTabMatches == 0 and matchingTab then
			windowObj:SelectTab(matchingTab)
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		applySearch(searchBox.Text)
	end)

	-- Ctrl+K search hotkey
	local inputConn = UserInputService.InputBegan:Connect(function(input, processed)
		if not processed then
			if input.KeyCode == toggleKey then
				windowObj:Toggle()
			elseif input.KeyCode == Enum.KeyCode.K and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
				searchBox:CaptureFocus()
			end
		end
	end)
	maid:Give(inputConn)

	-- Window Visibility & Animations
	function windowObj:Toggle(visible)
		if visible ~= nil then
			isVisible = visible
		else
			isVisible = not isVisible
		end

		if isVisible then
			main.Visible = true
			launcher:SetVisible(false)
			Elements.Tween(mainScale, TweenInfo.new(Motion.Duration.Base, Motion.Easing.QuintOut), {
				Scale = 1.0,
			})
		else
			launcher:SetVisible(true)
			local outTween = Elements.Tween(mainScale, TweenInfo.new(Motion.Duration.Fast, Motion.Easing.QuadIn), {
				Scale = 0.95,
			})
			outTween.Completed:Connect(function()
				if not isVisible then
					main.Visible = false
				end
			end)
		end
	end

	function windowObj:Minimize()
		self:Toggle(false)
	end

	function windowObj:ToggleMaximize()
		local camera = workspace.CurrentCamera
		local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)

		if not isMaximized then
			previousSize = main.Size
			previousPosition = main.Position
			isMaximized = true
			local maxW = math.clamp(vp.X - 48, 720, 1100)
			local maxH = math.clamp(vp.Y - 64, 480, 800)
			Elements.Tween(main, TweenInfo.new(Motion.Duration.Base, Motion.Easing.QuintOut), {
				Size = UDim2.fromOffset(maxW, maxH),
				Position = UDim2.fromScale(0.5, 0.5),
			})
		else
			isMaximized = false
			Elements.Tween(main, TweenInfo.new(Motion.Duration.Base, Motion.Easing.QuintOut), {
				Size = previousSize,
				Position = previousPosition,
			})
		end
	end

	-- Traffic-Light Clicks
	closeBtn.MouseButton1Click:Connect(function()
		windowObj:Toggle(false)
	end)

	minBtn.MouseButton1Click:Connect(function()
		windowObj:Minimize()
	end)

	maxBtn.MouseButton1Click:Connect(function()
		windowObj:ToggleMaximize()
	end)

	-- Resize Handle (Bottom-Right)
	if options.Resizable ~= false then
		local resizeHandle = Elements.Create("TextButton", {
			Name = "ResizeHandle",
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -2, 1, -2),
			BackgroundTransparency = 1,
			Text = "◢",
			TextColor3 = Theme.Get("TertiaryText"),
			TextSize = 10,
			Font = Enum.Font.GothamMedium,
			AutoButtonColor = false,
			ZIndex = 50,
			Parent = main,
		})
		Theme.Register(resizeHandle, "TextColor3", "TertiaryText")

		local isResizing = false
		local startPos = Vector2.new()
		local startSize = Vector2.new()

		resizeHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isResizing = true
				startPos = Vector2.new(input.Position.X, input.Position.Y)
				startSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
			end
		end)

		local resizeInputConn = UserInputService.InputChanged:Connect(function(input)
			if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = Vector2.new(input.Position.X - startPos.X, input.Position.Y - startPos.Y)
				local newW = math.clamp(startSize.X + delta.X, 520, 1200)
				local newH = math.clamp(startSize.Y + delta.Y, 360, 900)
				main.Size = UDim2.fromOffset(newW, newH)
			end
		end)
		maid:Give(resizeInputConn)

		local resizeEndConn = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isResizing = false
			end
		end)
		maid:Give(resizeEndConn)
	end

	function windowObj:SetStatus(text)
		statusBar:SetText(text)
	end

	function windowObj:SetWatermark(text)
		statusBar:SetText(text)
	end

	return windowObj
end

return Window
