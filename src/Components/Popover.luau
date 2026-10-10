--!strict
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Elements = require(script.Parent.Parent.Core.Elements)

local Popover = {}

local popoverLayer: Frame? = nil
local activeContent: GuiObject? = nil
local activeAnchor: GuiObject? = nil
local closeCallback: (() -> ())? = nil
local inputConnection: RBXScriptConnection? = nil

function Popover.Init(gui: ScreenGui, maid: any?)
	if popoverLayer and popoverLayer.Parent then return end

	popoverLayer = Elements.Create("Frame", {
		Name = "VynxPopoverLayer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1000,
		Parent = gui,
	}) :: Frame

	if inputConnection then
		inputConnection:Disconnect()
	end

	inputConnection = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if not activeContent or not activeAnchor then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local pos = Vector2.new(input.Position.X, input.Position.Y)

			local cPos, cSize = activeContent.AbsolutePosition, activeContent.AbsoluteSize
			local inContent = pos.X >= cPos.X and pos.X <= cPos.X + cSize.X and pos.Y >= cPos.Y and pos.Y <= cPos.Y + cSize.Y

			local aPos, aSize = activeAnchor.AbsolutePosition, activeAnchor.AbsoluteSize
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

function Popover.Open(content: GuiObject, anchor: GuiObject, onClose: (() -> ())?)
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

	-- Calculate position based on anchor's AbsolutePosition
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
	-- If it overflows below, display above the anchor
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
