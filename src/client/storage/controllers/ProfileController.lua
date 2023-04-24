-- Timestamp // 02/01/2023 15:08:36 MNT
-- Author // @iohgoodness
-- Description // For wiping this player's profile
--// In the future there could of course be other uses here, wiping is very important when complying with GDPR

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ProfileController = Knit.CreateController { Name = "ProfileController" }

local frontScreenGui = Knit.playerGui:WaitForChild('Notes')
local wipeButton = frontScreenGui:WaitForChild('Wipe')

function ProfileController:KnitStart()
    local ProfileService = Knit.GetService("ProfileService")
    wipeButton.Activated:Connect(function()
        ProfileService.WipeProfile:Fire()
    end)
end

return ProfileController
