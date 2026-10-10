local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Drag = {}

function Drag.Make(target, handle, smoothness, maid)
	local alpha = smoothness or 0.25
	local dragging = false
	local dragStartPos = Vector2.zero
	local frameStartPos = UDim2.new()
	local targetPos = target.Position

	local dragInput = nil

	local function clampToScreen(pos)
		local camera = Workspace.CurrentCamera
		local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
		local size = target.AbsoluteSize
		local anchor = target.AnchorPoint

		local absX = (pos.X.Scale * viewport.X) + pos.X.Offset
		local absY = (pos.Y.Scale * viewport.Y) + pos.Y.Offset

		local minX = anchor.X * size.X
		local maxX = viewport.X - ((1 - anchor.X) * size.X)
		local minY = anchor.Y * size.Y
		local maxY = viewport.Y - ((1 - anchor.Y) * size.Y)

		local clampedX = math.clamp(absX, minX, math.max(minX, maxX))
		local clampedY = math.clamp(absY, minY, math.max(minY, maxY))

		return UDim2.fromOffset(clampedX, clampedY)
	end

	local c1 = handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
			frameStartPos = target.Position
			dragInput = input

			local cEnd
			cEnd = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragInput = nil
					cEnd:Disconnect()
				end
			end)
		end
	end)

	local c2 = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
			local proposed = UDim2.new(
				frameStartPos.X.Scale,
				frameStartPos.X.Offset + delta.X,
				frameStartPos.Y.Scale,
				frameStartPos.Y.Offset + delta.Y
			)
			targetPos = clampToScreen(proposed)
		end
	end)

	local c3 = RunService.RenderStepped:Connect(function(dt)
		if not target.Parent then return end
		if smoothness and smoothness > 0 then
			local currentX = target.Position.X.Offset
			local currentY = target.Position.Y.Offset
			local goalX = targetPos.X.Offset
			local goalY = targetPos.Y.Offset

			local lerpX = currentX + (goalX - currentX) * math.clamp(alpha * (dt * 60), 0, 1)
			local lerpY = currentY + (goalY - currentY) * math.clamp(alpha * (dt * 60), 0, 1)

			target.Position = UDim2.new(targetPos.X.Scale, math.round(lerpX), targetPos.Y.Scale, math.round(lerpY))
		else
			target.Position = targetPos
		end
	end)

	if maid then
		maid:Give(c1)
		maid:Give(c2)
		maid:Give(c3)
	end

	target.Destroying:Connect(function()
		c1:Disconnect()
		c2:Disconnect()
		c3:Disconnect()
	end)
end

return Drag
