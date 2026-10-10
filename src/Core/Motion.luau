local TweenService = game:GetService("TweenService")

local Duration = {
	Fast = 0.12,
	Base = 0.20,
	Slow = 0.35,
}

local Easing = {
	QuadOut = Enum.EasingStyle.Quad,
	QuadIn = Enum.EasingStyle.Quad,
	QuintOut = Enum.EasingStyle.Quint,
	QuintIn = Enum.EasingStyle.Quint,
	BackOut = Enum.EasingStyle.Back,
	BackIn = Enum.EasingStyle.Back,
}

local Motion = {
	Fast = Duration.Fast,
	Base = Duration.Base,
	Slow = Duration.Slow,
	Duration = Duration,
	Easing = Easing,
	DefaultEasing = Enum.EasingStyle.Quad,
	DefaultDirection = Enum.EasingDirection.Out,
	QuintEasing = Enum.EasingStyle.Quint,
}

function Motion.Tween(instance, duration, goal, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(
		duration or Motion.Base,
		easingStyle or Motion.DefaultEasing,
		easingDirection or Motion.DefaultDirection
	)
	local tween = TweenService:Create(instance, tweenInfo, goal)
	tween:Play()
	return tween
end

function Motion.SpringTween(instance, duration, goal)
	local tweenInfo = TweenInfo.new(
		duration or Motion.Base,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, tweenInfo, goal)
	tween:Play()
	return tween
end

return Motion
