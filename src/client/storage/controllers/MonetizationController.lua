-- Timestamp // 02/01/2023 11:47:42 MNT
-- Author // @iohgoodness
-- Description // For a client to call monetization methods (often from UI)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local MonetizationController = Knit.CreateController { Name = "MonetizationController" }

--# Generic functions allowing a quick prompt for a player to buy a gamepass or devproduct from the client
function MonetizationController:Gamepass(id)
    local hasPass = false
    local success, message = pcall(function()
        hasPass = MarketplaceService:UserOwnsGamePassAsync(Knit.player.UserId, id)
    end)
    if not success then
        warn("Error while checking if player has pass: " .. tostring(message))
        return
    end
    if not hasPass then
        MarketplaceService:PromptGamePassPurchase(Knit.player, id)
    end
end
function MonetizationController:Devproduct(id)
    MarketplaceService:PromptProductPurchase(Knit.player, id)
end

--# Time travel init function for that gamepass
function MonetizationController:TimeTravel()
    local player = Knit.player
    local character = player.Character or player.CharacterAdded:Wait()
    if not character then return end
    local humanoid = character:WaitForChild('Humanoid')
    local Animator = humanoid:WaitForChild("Animator")
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://10714347256'
    local godTrack = Animator:LoadAnimation(animation)
    godTrack.Priority = Enum.AnimationPriority.Action
    godTrack.Looped = false
    local MonetizationService = Knit.GetService("MonetizationService")
    MonetizationService.ActivateTimeTravel:Connect(function(play)
        if play then
            godTrack:Play()
        else
            godTrack:Stop()
        end
    end)
end

function MonetizationController:KnitStart()
    self:TimeTravel()
end

return MonetizationController