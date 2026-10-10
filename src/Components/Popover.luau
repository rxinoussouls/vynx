local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Elements = require(script.Parent.Parent.Core.Elements)

local Popover = {}

local popoverLayer = nil
local activeContent = nil
local activeAnchor = nil
local closeCallback = nil
local inputConnection = nil

function Popover.Init(gui, maid)
	if popoverLayer and popoverLayer.Parent then return end

	popoverLayer = Elements.Create("Frame", {
		Name = "VynxPopoverLayer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1000,
		Parent = gui,
	})

	if inputConnection then
		inputConnection:Disconnect()
	end

	inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
		if not activeContent or not activeAnchor then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local pos = Vector2.new(input.Position.X, input.Position.Y)

			local cPos = activeContent.AbsolutePosition
			local cSize = activeContent.AbsoluteSize
			local inContent = pos.X >= cPos.X and pos.X <= cPos.X + cSize.X and pos.Y >= cPos.Y and pos.Y <= cPos.Y + cSize.Y

			local aPos = activeAnchor.AbsolutePosition
			local aSize = activeAnchor.AbsoluteSize
			local inAnchor = pos.X >= aPos.X and pos.X <= aPos.X + aSize.X and pos.Y >= aPos.Y and pos.Y <= aPos.Y + aSize.Y

			if not inContent and not inAnchor then
				Popover.Close()
			end
		end
	end)

	if maid then
		maid:Give(inputConnection)
	end
end

function Popover.Open(content, anchor, onClose)
	if not popoverLayer then return end
	if activeContent == content then
		Popover.Close()
		return
	end

	Popover.Close()

	activeContent = content
	activeAnchor = anchor
	closeCallback = onClose

	content.Parent = popoverLayer
	content.Visible = true

	local aPos = anchor.AbsolutePosition
	local aSize = anchor.AbsoluteSize
	local cSize = content.AbsoluteSize
	local cam = Workspace.CurrentCamera
	local viewSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)

	local targetX = aPos.X
	if targetX + cSize.X > viewSize.X - 10 then
		targetX = viewSize.X - cSize.X - 10
	end

	local targetY = aPos.Y + aSize.Y + 4
	if targetY + cSize.Y > viewSize.Y - 10 then
		targetY = aPos.Y - cSize.Y - 4
	end

	content.Position = UDim2.fromOffset(math.max(10, targetX), math.max(10, targetY))
end

function Popover.Close()
	if activeContent then
		activeContent.Visible = false
		activeContent.Parent = nil
		activeContent = nil
		activeAnchor = nil
		if closeCallback then
			local cb = closeCallback
			closeCallback = nil
			task.spawn(cb)
		end
	end
end

function Popover.Clean()
	Popover.Close()
	if inputConnection then
		inputConnection:Disconnect()
		inputConnection = nil
	end
	if popoverLayer then
		popoverLayer:Destroy()
		popoverLayer = nil
	end
end

return Popover
