--!strict
local TweenService = game:GetService("TweenService")

local Elements = {}

function Elements.Create(className: string, properties: { [string]: any }?, children: { Instance }?): Instance
	local instance = Instance.new(className)
	local targetParent: Instance? = nil

	if properties then
		for key, value in pairs(properties) do
			if key == "Parent" then
				targetParent = value
			else
				(instance :: any)[key] = value
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end

	-- Parent is always assigned last to prevent unneeded property updates during tree insertion
	if targetParent then
		instance.Parent = targetParent
	end

	return instance
end

function Elements.Round(target: Instance, radius: number?): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = target
	return corner
end

function Elements.Stroke(target: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(45, 45, 55)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = target
	return stroke
end

function Elements.Padding(target: Instance, pad: number | { Top: number?, Bottom: number?, Left: number?, Right: number? }): UIPadding
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

function Elements.Scale(target: Instance, scale: number?): UIScale
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = scale or 1
	uiScale.Parent = target
	return uiScale
end

function Elements.Gradient(target: Instance, colors: ColorSequence?, rotation: number?, transparency: NumberSequence?): UIGradient
	local grad = Instance.new("UIGradient")
	if colors then grad.Color = colors end
	if rotation then grad.Rotation = rotation end
	if transparency then grad.Transparency = transparency end
	grad.Parent = target
	return grad
end

function Elements.Tween(target: Instance, info: TweenInfo, properties: { [string]: any }): Tween
	local tween = TweenService:Create(target, info, properties)
	tween:Play()
	return tween
end

return Elements
