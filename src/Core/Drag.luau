--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Drag = {}

function Drag.Make(target: GuiObject, handle: GuiObject, smoothness: number?)
	local alpha = smoothness or 0.25
	local dragging = false
	local dragStartPos = Vector2.zero
	local frameStartPos = UDim2.new()
	local targetPos = target.Position

	local dragInput: InputObject? = nil

	local function onInputBegan(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
			frameStartPos = target.Position
			dragInput = input

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragInput = nil
				end
			end)
		end
	end

	handle.InputBegan:Connect(onInputBegan)

	UserInputService.InputChanged:Connect(function(input: InputObject)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
			targetPos = UDim2.new(
				frameStartPos.X.Scale,
				frameStartPos.X.Offset + delta.X,
				frameStartPos.Y.Scale,
				frameStartPos.Y.Offset + delta.Y
			)
		end
	end)

	local connection = RunService.RenderStepped:Connect(function(dt: number)
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

	target.Destroying:Connect(function()
		connection:Disconnect()
	end)
end

return Drag
