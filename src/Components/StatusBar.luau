local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local Elements = require(script.Parent.Parent.Core.Elements)
local Theme = require(script.Parent.Parent.Core.Theme)

local StatusBar = {}

function StatusBar.New(parent, options, library)
	options = options or {}
	local maid = library.Maid

	local bar = Elements.Create("Frame", {
		Name = "StatusBar",
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24),
		BackgroundColor3 = Theme.Get("Sidebar"),
		BorderSizePixel = 0,
		Parent = parent,
	})
	Theme.Register(bar, "BackgroundColor3", "Sidebar")

	local topHairline = Elements.Hairline(bar, "Top")

	local padding = Elements.Padding(bar, { Top = 0, Bottom = 0, Left = 12, Right = 12 })

	local leftLabel = Elements.Create("TextLabel", {
		Name = "StatusLeft",
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = options.DefaultText or "vynx  •  ready",
		TextColor3 = Theme.Get("SecondaryText"),
		TextSize = Theme.Typography.Caption.Size,
		Font = Theme.Typography.Caption.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = bar,
	})
	Theme.Register(leftLabel, "TextColor3", "SecondaryText")

	local rightLabel = Elements.Create("TextLabel", {
		Name = "StatusRight",
		Size = UDim2.new(0.4, 0, 1, 0),
		Position = UDim2.new(0.6, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "60 fps",
		TextColor3 = Theme.Get("TertiaryText"),
		TextSize = Theme.Typography.Caption.Size,
		Font = Theme.Typography.Caption.Font,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = bar,
	})
	Theme.Register(rightLabel, "TextColor3", "TertiaryText")

	local frameCount = 0
	local lastTime = os.clock()
	local fpsConn = RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		local now = os.clock()
		if now - lastTime >= 1 then
			local fps = math.round(frameCount / (now - lastTime))
			local pingMs = 0
			pcall(function()
				local perfStats = StatsService:FindFirstChild("PerformanceStats")
				if perfStats then
					local pingStat = perfStats:FindFirstChild("Ping")
					if pingStat then
						pingMs = math.round(pingStat:GetValue())
					end
				end
			end)

			if pingMs > 0 then
				rightLabel.Text = string.format("%d fps  •  %d ms", fps, pingMs)
			else
				rightLabel.Text = string.format("%d fps", fps)
			end
			frameCount = 0
			lastTime = now
		end
	end)
	maid:Give(fpsConn)

	local statusBarObj = {
		Frame = bar,
		SetText = function(self, text)
			leftLabel.Text = text
		end,
		SetVisible = function(self, visible)
			bar.Visible = visible
		end,
	}

	return statusBarObj
end

return StatusBar
