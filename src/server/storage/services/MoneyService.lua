-- Timestamp // 01/26/2023 21:12:04 MNT
-- Author // @iohgoodness
-- Description // Service to manage the collection of cash from the player
--// Using knit we create a remote that the client can listen to when we want to update money

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local MoneyService = Knit.CreateService {
    Name = "MoneyService",
    Client = {
        UpdateMoney = Knit.CreateSignal(),
    },
}

function MoneyService:AddMoney(player, change)
    Knit.gp(player).Data.Money += change
    self.Client.UpdateMoney:Fire(player, Knit.gp(player).Data.Money, change)
end

function MoneyService:Incoming(player)
    self.Client.UpdateMoney:Fire(player, Knit.gp(player).Data.Money)
    --# Money giver (for testing animation)
    --[[ task.spawn(function()
        while player and player.Parent do
            task.wait(1)
            self:AddMoney(player, math.random(200, 1500))
        end
    end) ]]
end

return MoneyService
