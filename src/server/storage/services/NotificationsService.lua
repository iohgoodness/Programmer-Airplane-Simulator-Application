-- Timestamp // 01/31/2023 13:31:25 MNT
-- Author // @iohgoodness
-- Description // For notifying the client various information
--// for this place, just a notification if there is an issue buying something (not enough money or dependency), normally this Service is much more filled out in games!

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local NotificationsService = Knit.CreateService {
    Name = "NotificationsService",
    Client = {
        NotifyTopBox = Knit.CreateSignal(),
    },
}

function NotificationsService:NotifyTopBox(player, info)
    self.Client.NotifyTopBox:Fire(player, info)
end

return NotificationsService
