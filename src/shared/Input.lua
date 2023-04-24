local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

return {
    Enable = function()
        UserInputService.ModalEnabled = false
        ContextActionService:UnbindAction("freezeMovement")
    end,
    Disable = function()
        UserInputService.ModalEnabled = true
        ContextActionService:BindAction(
            "freezeMovement",
            function() return Enum.ContextActionResult.Sink end,
            false,
            unpack(Enum.PlayerActions:GetEnumItems())
        )
    end,
}