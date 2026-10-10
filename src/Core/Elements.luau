local TweenService = game:GetService("TweenService")

local Elements = {}

function Elements.Create(className, properties, children)
	local instance = Instance.new(className)
	local targetParent = nil

	if properties then
		for key, value in pairs(properties) do
			if key == "Parent" then
				targetParent = value
			else
				instance[key] = value
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end

	if targetParent then
		instance.Parent = targetParent
	end

	return instance
end

function Elements.Round(target, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = target
	return corner
end

function Elements.Stroke(target, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(45, 45, 55)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = target
	return stroke
end

function Elements.Padding(target, pad)
	local padding = Instance.new("UIPadding")
	if typeof(pad) == "number" then
		padding.PaddingTop = UDim.new(0, pad)
		padding.PaddingBottom = UDim.new(0, pad)
		padding.PaddingLeft = UDim.new(0, pad)
		padding.PaddingRight = UDim.new(0, pad)
	elseif typeof(pad) == "table" then
		padding.PaddingTop = UDim.new(0, pad.Top or 0)
		padding.PaddingBottom = UDim.new(0, pad.Bottom or 0)
		padding.PaddingLeft = UDim.new(0, pad.Left or 0)
		padding.PaddingRight = UDim.new(0, pad.Right or 0)
	end
	padding.Parent = target
	return padding
end

function Elements.Scale(target, scale)
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = scale or 1
	uiScale.Parent = target
	return uiScale
end

function Elements.Gradient(target, colors, rotation, transparency)
	local grad = Instance.new("UIGradient")
	if colors then grad.Color = colors end
	if rotation then grad.Rotation = rotation end
	if transparency then grad.Transparency = transparency end
	grad.Parent = target
	return grad
end

function Elements.Shadow(target, radius, opacity)
	local shadowHolder = Instance.new("Frame")
	shadowHolder.Name = "ShadowHolder"
	shadowHolder.AnchorPoint = target.AnchorPoint
	shadowHolder.Size = UDim2.new(target.Size.X.Scale, target.Size.X.Offset + 16, target.Size.Y.Scale, target.Size.Y.Offset + 16)
	shadowHolder.Position = UDim2.new(target.Position.X.Scale, target.Position.X.Offset, target.Position.Y.Scale, target.Position.Y.Offset + 4)
	shadowHolder.BackgroundTransparency = 1
	shadowHolder.ZIndex = math.max(1, (target.ZIndex or 2) - 1)
	shadowHolder.Parent = target.Parent

	-- 3-layer stacked soft shadow without external images
	for i = 1, 3 do
		local layer = Instance.new("Frame")
		layer.Name = "ShadowLayer" .. i
		layer.Size = UDim2.new(1, i * 4, 1, i * 4)
		layer.Position = UDim2.new(0.5, 0, 0.5, i * 2)
		layer.AnchorPoint = Vector2.new(0.5, 0.5)
		layer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		layer.BackgroundTransparency = (opacity or 0.7) + (i * 0.08)
		layer.BorderSizePixel = 0
		layer.ZIndex = shadowHolder.ZIndex
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, (radius or 12) + i * 2)
		corner.Parent = layer
		layer.Parent = shadowHolder
	end

	local function sync()
		shadowHolder.Visible = target.Visible
		shadowHolder.AnchorPoint = target.AnchorPoint
		shadowHolder.Position = UDim2.new(target.Position.X.Scale, target.Position.X.Offset, target.Position.Y.Scale, target.Position.Y.Offset + 4)
		shadowHolder.Size = UDim2.new(target.Size.X.Scale, target.Size.X.Offset + 16, target.Size.Y.Scale, target.Size.Y.Offset + 16)
	end

	target:GetPropertyChangedSignal("Visible"):Connect(sync)
	target:GetPropertyChangedSignal("Position"):Connect(sync)
	target:GetPropertyChangedSignal("Size"):Connect(sync)
	target:GetPropertyChangedSignal("AnchorPoint"):Connect(sync)

	target.Destroying:Connect(function()
		shadowHolder:Destroy()
	end)

	return shadowHolder
end

function Elements.Hairline(target, sideOrInset, inset)
	local hairline = Instance.new("Frame")
	hairline.Name = "Hairline"
	hairline.BorderSizePixel = 0
	hairline.ZIndex = (target.ZIndex or 2) + 1
	hairline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hairline.BackgroundTransparency = 0.92

	if typeof(sideOrInset) == "string" then
		local side = string.lower(sideOrInset)
		if side == "top" then
			hairline.Size = UDim2.new(1, 0, 0, 1)
			hairline.Position = UDim2.new(0, 0, 0, 0)
		elseif side == "bottom" then
			hairline.Size = UDim2.new(1, 0, 0, 1)
			hairline.Position = UDim2.new(0, 0, 1, -1)
		elseif side == "left" then
			hairline.Size = UDim2.new(0, 1, 1, 0)
			hairline.Position = UDim2.new(0, 0, 0, 0)
		elseif side == "right" then
			hairline.Size = UDim2.new(0, 1, 1, 0)
			hairline.Position = UDim2.new(1, -1, 0, 0)
		else
			hairline.Size = UDim2.new(1, 0, 0, 1)
			hairline.Position = UDim2.new(0, 0, 1, -1)
		end
	else
		local insetLeft = typeof(sideOrInset) == "number" and sideOrInset or 12
		hairline.Size = UDim2.new(1, -insetLeft, 0, 1)
		hairline.Position = UDim2.new(0, insetLeft, 1, -1)
	end

	hairline.Parent = target
	return hairline
end

function Elements.Tween(target, info, properties)
	local tween = TweenService:Create(target, info, properties)
	tween:Play()
	return tween
end

return Elements
