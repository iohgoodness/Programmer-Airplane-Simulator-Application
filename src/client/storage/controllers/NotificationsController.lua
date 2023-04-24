-- Timestamp // 01/31/2023 13:29:58 MNT
-- Author // @iohgoodness
-- Description // For any notifications
--// Games should always have a way to easily communicate to the client
--// server details that aren't totally clear. This is a very simple version of that.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local NotificationsController = Knit.CreateController { Name = "NotificationsController" }

local frontScreenGui = Knit.playerGui:WaitForChild('Notification')
local frame = frontScreenGui:WaitForChild('Frame')
local topBoxText = frame:WaitForChild('TextLabel')

local Tween = Knit.common.Interface.Tween

function NotificationsController:KnitStart()
    local NotificationsService = Knit.GetService('NotificationsService')
    local debounce = false
    NotificationsService.NotifyTopBox:Connect(function(info)
        if debounce then return end
        debounce = true
        topBoxText.Text = info
        Tween(frame, {Position = UDim2.fromScale(.5, 0.03)})
        task.wait(.9)
        Tween(frame, {Position = UDim2.fromScale(.5, -0.2)})
        task.wait(.2)
        debounce = false
    end)
end

return NotificationsController
