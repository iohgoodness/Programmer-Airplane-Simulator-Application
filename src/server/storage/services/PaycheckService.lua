-- Timestamp // 01/26/2023 21:12:04 MNT
-- Author // @iohgoodness
-- Description // Service to manage the collection of cash from the player
--// Using knit we create a remote that the client can listen to when we want to update money

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PaycheckService = Knit.CreateService {
    Name = "PaycheckService",
    Client = {
        UpdateScreens = Knit.CreateSignal(),
    },
}

--# collect all screens that will be updated (this assumes setup has been done the same when "building/placing" the models)
function PaycheckService:AddScreenMoney(player, change)
    local profile = Knit.gp(player)
    if not profile then return end
    local screens = {}
    for _,paycheckMachine in pairs(workspace.PaycheckMachines:GetChildren()) do
        table.insert(screens, paycheckMachine.Money_Info_Text.SurfaceGui.MoneyLabel)
    end
    profile.Data.ScreenMoney += change
    self.Client.UpdateScreens:Fire(player, screens, profile.Data.ScreenMoney, change)
end

--# moves screen money to ui/real money (moves the paycheck to the pocket!)
function PaycheckService:CollectScreenMoney(player)
    local profile = Knit.gp(player)
    if not profile then return end
    local screenMoney = profile.Data.ScreenMoney
    profile.Data.ScreenMoney = 0
    self:AddScreenMoney(player, 0)
    self._MoneyService:AddMoney(player, screenMoney)
end

function PaycheckService:KnitInit()
    self.WaitTime = 1
    self.TimeSkip = false
    self.MoneyPerWaitTime = 100
    self._SoundsService = Knit.GetService('SoundsService')
    self._MoneyService = Knit.GetService('MoneyService')
end

function PaycheckService:Incoming(player)
    self:AddScreenMoney(player, 0) --# init screens
    task.spawn(function()
        while player and player.Parent do
            if self.TimeSkip then task.wait() continue end
            task.wait(self.WaitTime)

            --# important to note from the line below, the player could lose out on potential money being earned
            --[[ if self._collectingDebounce then continue end ]]
            --# this line below would allow the player to "catch" more money, however it would also force a single task.wait() every iteration of the loop
            --[[ repeat task.wait() until self._collectingDebounce==false ]]
            --# this last line below would fix both of these issues, one if statement then only waiting until absolutely necessary to give the player money again
            if self._collectingDebounce then repeat task.wait() until self._collectingDebounce==false end

            self:AddScreenMoney(player, self.MoneyPerWaitTime)
        end
    end)
    --# classic debounce ensuring that .Touched function doesn't run multiple times compromising the integrity of the player's important values
    self._collectingDebounce = false
    for _,paycheckMachine in pairs(workspace.PaycheckMachines:GetChildren()) do
        local pad = paycheckMachine.PadComponents.Pad
        pad.Touched:Connect(function(hit)
            if self._collectingDebounce then return end
            self._collectingDebounce = true
            if not hit.Parent then return end
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if not player then return end
            self:CollectScreenMoney(player)
            self._SoundsService:Play('AddedMoney', pad)
            paycheckMachine.Effect.Coins_1.Enabled = true
            task.wait(.7)
            paycheckMachine.Effect.Coins_1.Enabled = false
            task.wait(1)
            self._collectingDebounce = false
        end)
    end
end

return PaycheckService
