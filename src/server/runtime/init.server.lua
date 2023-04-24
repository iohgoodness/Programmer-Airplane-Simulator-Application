-- Timestamp // 01/26/2023 20:59:05 MNT
-- Author // @iohgoodness
-- Description // Knit bootstrap

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")

Knit.common = require(ReplicatedStorage:WaitForChild('shared-sync'):WaitForChild('Import'))

Knit.AddServicesDeep(game.ServerStorage['server-sync'].services)

Knit.gp = function(player)
    return Knit.GetService('ProfileService').Profiles[player]
end

Knit.Start():andThen(function()
    print('Knit Server Started')
end):catch(warn)

--# These are some helpful custom functions for catching Incoming/Removing players
local function Incoming(player)
    local ProfileService = Knit.GetService('ProfileService')
    repeat task.wait() until ProfileService.Ready[player]
    for _,service in pairs(Knit.GetAllServices()) do
        if not service.Incoming then continue end
        task.spawn(function() service.Incoming(service, player) end)
    end
end
local function Removing(player)
    local ProfileService = Knit.GetService('ProfileService')
    repeat task.wait() until ProfileService.Ready[player]
    for _,service in pairs(Knit.GetAllServices()) do
        if not service.Removing then continue end
        task.spawn(function() service.Removing(service, player) end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do task.spawn(function() Incoming(player) end) end
Players.PlayerAdded:Connect(function(player) Incoming(player) end)
Players.PlayerRemoving:Connect(function(player) Removing(player) end)