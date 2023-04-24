local TweenService = game:GetService("TweenService")

return {
    Tween = function(obj, tbl, timer, easingStyle, easingDirection, repeatCount, reverses)
        TweenService:Create(obj, TweenInfo.new(timer or 0.21, easingStyle or Enum.EasingStyle.Linear, easingDirection or Enum.EasingDirection.InOut, repeatCount or 0, reverses or false), tbl):Play()
    end,
}