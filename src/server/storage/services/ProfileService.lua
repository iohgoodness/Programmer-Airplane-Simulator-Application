-- Timestamp // 01/26/2023 21:25:59 MNT
-- Author // @iohgoodness
-- Description // Implementation of the ProfileService
--// Credit can be found here: https://github.com/MadStudioRoblox/ProfileService/
--// "ProfileService is a stand-alone ModuleScript that specialises in loading and auto-saving DataStore profiles."
--// An effective demonstration of using an external library to handle player data saving (and many issues that could arise with datasaving)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ProfileTemplate = {
    Money = 0,
    Tycoon = {Owned = { --[[ "pad1/object1", ]] }},
    ScreenMoney = 0,
}

local Players = game:GetService("Players")

local GameProfileStore = require(game.ServerStorage['server-sync'].class.ProfileService).GetProfileStore(
    --[[ `PlayerData.v.{tostring(tick())}`, ]] --# for testing with a new datastore every time
    `PlayerData.v.1.06`,
    ProfileTemplate
)

local ProfileService = Knit.CreateService {
    Name = "ProfileService",
    Client = {
        WipeProfile = Knit.CreateSignal(),
    },
}

ProfileService.Ready = {}
ProfileService.Profiles = {}
ProfileService.WipeRequest = {}

function ProfileService:PlayerAdded(player)
    local profile = GameProfileStore:LoadProfileAsync("Player_" .. player.UserId)
    if profile ~= nil then
        profile:AddUserId(player.UserId)
        profile:Reconcile()
        profile:ListenToRelease(function()
            self.Profiles[player] = nil
            if ProfileService.WipeRequest[player] then
                local key = "Player_" .. player.UserId
                GameProfileStore:WipeProfileAsync(key)
                ProfileService.WipeRequest[player] = nil
            end
            player:Kick()
        end)
        if player:IsDescendantOf(Players) == true then
            self.Profiles[player] = profile
            ProfileService.Ready[player] = true
        else
            profile:Release()
        end
    else
        player:Kick()
    end
end

function ProfileService:Wipe(player)
    ProfileService.WipeRequest[player] = true
    player:Kick('Your data will be wiped!')
end

function ProfileService:KnitInit()
    self.Client.WipeProfile:Connect(function(player)
        local success = self:Wipe(player)
        if success then
            player:Kick('Your data was wiped! Join back and you will have a new datastore to work with!')
        end
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function() self:PlayerAdded(player) end)
    end
    Players.PlayerAdded:Connect(function(player) self:PlayerAdded(player) end)
    Players.PlayerRemoving:Connect(function(player)
        local profile = self.Profiles[player]
        if profile ~= nil then
            profile:Release()
        end
        ProfileService.Ready[player] = nil
    end)
end

return ProfileService
