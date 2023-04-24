-- Timestamp // 01/26/2023 21:12:35 MNT
-- Author // @iohgoodness
-- Description // Service to step on pads to add things to the player's tycoon

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Abbreviate = Knit.common.Math.Abbreviate

local FORCE_PARENT_DELAY = 3

local PadService = Knit.CreateService {
    Name = "PadService",
    Client = {
        NewModel = Knit.CreateSignal(),
        ClientFinishAnim = Knit.CreateSignal(),
    },
}

function PadService:KnitInit()
    self._playerFinishAnim = {}
    self._MoneyService = Knit.GetService('MoneyService')
    self._NotificationsService = Knit.GetService('NotificationsService')
    self._SoundsService = Knit.GetService('SoundsService')
    self._MonetizationService = Knit.GetService('MonetizationService')
    self.Client.ClientFinishAnim:Connect(function(player)
        if table.find(self._playerFinishAnim, player) then return end
        table.insert(self._playerFinishAnim, player)
    end)
end

--# The server of course will want to update so that any clients not here during the "buying animation", are updated
--# this quick helper table self._playerFinishAnim allows us to check to see if the player has finished the animation or otherwise just place the model as it should
function PadService:SpawnBuilding(player, model, padModel)
    model.Parent = ReplicatedStorage
    self.Client.NewModel:FireAll(model, padModel)
    local timer = tick()
    repeat task.wait() until tick()>timer+FORCE_PARENT_DELAY or table.find(self._playerFinishAnim, player)
    local index = table.find(self._playerFinishAnim, player)
    if index then table.remove(self._playerFinishAnim, index) end
    model.Parent = workspace
    padModel:Destroy()
end

function PadService:Incoming(player)
    --# reminder: Knit.gp(player).Data.Tycoon.Owned = {"padName/objName",}
    --# load existing tycoon
    for _,btnObjName in pairs(Knit.gp(player).Data.Tycoon.Owned) do
        local parsed = btnObjName:split('/')
        local padName,objName = parsed[1],parsed[2]
        local padModel = workspace.Pads:FindFirstChild(padName)
        if not padModel then continue end
        local target = padModel:FindFirstChild('Target')
        target.Parent = workspace
        padModel:Destroy()
    end
    --# any pad not removed should then have another object that it normally would unlock removed
    for _,padModel in pairs(workspace.Pads:GetChildren()) do
        if not padModel:FindFirstChild('Target') then warn(`A pad model {padModel} {tostring(padModel)} doesn't have a target!`) continue end
        local target = padModel.Target.Value
        target.Parent = ServerStorage.SavedAssets
        local price = padModel:GetAttribute('Price')
        local gamepass = padModel:GetAttribute('Gamepass')
        if not price and not gamepass then warn(`A pad model {padModel} {tostring(padModel)} doesn't have a price!`) continue end
        padModel.BillboardGui.Frame.TitleLabel.Text = padModel.Name
        if not price then
            padModel.BillboardGui.Frame.BottomFrame.OuterBottomFrame.InnerBottomFrame.BottomLabel.Text = `R$ {padModel:GetAttribute('Robux')}`
        else
            padModel.BillboardGui.Frame.BottomFrame.OuterBottomFrame.InnerBottomFrame.BottomLabel.Text = `$ {Abbreviate(price)}`
        end
    end
    --# handle all buttons not already unlocked/purchased
    for _,padModel in pairs(workspace.Pads:GetChildren()) do
        local pad = padModel:FindFirstChild('Pad')
        local price = padModel:GetAttribute('Price')
        local gamepassId = padModel:GetAttribute('Gamepass')
        local target = padModel:FindFirstChild('Target').Value
        if not tonumber(price) and not gamepassId then warn(`A pad model {pad} {tostring(pad)} doesn't have a price!`) continue end
        if not pad then warn(`A pad model {pad} {tostring(pad)} is missing its actual pad!`) continue end
        local debounce = false
        pad.Touched:Connect(function(hit)
            if debounce then return end
            debounce = true
            if not hit.Parent then return end
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if not player then return end
            local profile = Knit.gp(player)
            if padModel:FindFirstChild('Dependency') then
                if padModel.Dependency.Value and padModel.Dependency.Value.Parent then
                    if padModel.Dependency.Value.Parent.Name == 'Pads' then
                        self._NotificationsService:NotifyTopBox(player, `You must first buy {tostring(padModel.Dependency.Value)}`)
                        self._SoundsService:Play('NotEnoughMoney', pad)
                        task.wait(2)
                        debounce = false
                        return
                    end
                end
            end
            if not price then
                self._MonetizationService:Gamepass(player, gamepassId)
            else
                if profile.Data.Money >= price then
                    self._MoneyService:AddMoney(player, -price)
                    table.insert(Knit.gp(player).Data.Tycoon.Owned, `{padModel.Name}/{tostring(target)}`)
                    self._SoundsService:Play('Purchased', hit.Parent)
                    self:SpawnBuilding(player, target, padModel)
                else
                    self._NotificationsService:NotifyTopBox(player, 'Not enough money!')
                    self._SoundsService:Play('NotEnoughMoney', pad)
                end
            end
            task.wait(2)
            debounce = false
        end)
    end
end

return PadService
