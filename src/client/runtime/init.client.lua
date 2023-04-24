-- Timestamp // 01/26/2023 20:59:05 MNT
-- Author // @iohgoodness
-- Description // Knit bootstrap

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")

Knit.player = Players.LocalPlayer
Knit.playerGui = Knit.player.PlayerGui
Knit.common = require(ReplicatedStorage:WaitForChild('shared-sync'):WaitForChild('Import'))

Knit.AddControllersDeep(ReplicatedStorage:WaitForChild('client-sync'):WaitForChild('controllers'))

Knit.Start():andThen(function()
    print('Knit Client Started')
end):catch(warn)