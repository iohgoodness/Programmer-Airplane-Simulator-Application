
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

return {
    ['000000000'] = function(player)
        local PadService = Knit.GetService('PadService')
        local PaycheckService = Knit.GetService('PaycheckService')
        local MonetizationService = Knit.GetService('MonetizationService')
        local SoundsService = Knit.GetService('SoundsService')
        if not table.find(Knit.gp(player).Data.Tycoon.Owned, 'Time Travel/Time Travel 3') then
            table.insert(Knit.gp(player).Data.Tycoon.Owned, 'Time Travel/Time Travel 3')
        end
        if not workspace.Buildings:FindFirstChild('Time Travel 3') then
            ServerStorage.SavedAssets['Time Travel 3'].Parent = workspace.Buildings
        end
        if workspace.Pads:FindFirstChild('Time Travel') then
            workspace.Pads['Time Travel']:Destroy()
        end
        local debounce = false
        local activate = workspace.Buildings['Time Travel 3'].Activate
        activate.ClickDetector.MouseClick:Connect(function()
            if debounce then return end
            debounce = true
            MonetizationService.Client.ActivateTimeTravel:Fire(player, true)
            local secondsIn12Hours = 12*60*60
            local totalMoneyToGive = secondsIn12Hours*PaycheckService.MoneyPerWaitTime
            local moneyIncrement = totalMoneyToGive/36
            local minutesAfterMidnight = 0
            PaycheckService.TimeSkip = true
            local total = 144*2
            SoundsService:Play('TimeTravel', activate)
            for i=1, total do
                minutesAfterMidnight+=10
                Lighting:SetMinutesAfterMidnight(minutesAfterMidnight)
                task.wait(.01)
                if i%(4*2)==0 then
                    --# will run 36 times as (144*2)/(4*2)=36
                    PaycheckService:AddScreenMoney(player, moneyIncrement)
                end
            end
            PaycheckService.TimeSkip = false
            MonetizationService.Client.ActivateTimeTravel:Fire(player, false)
            task.wait(2)
            debounce = false
        end)
        return true
    end,
}