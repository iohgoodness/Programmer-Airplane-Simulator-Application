-- Timestamp // 02/01/2023 13:51:51 MNT
-- Author // @iohgoodness
-- Description // Controlling the sounds on the server
--// It is important to note that choosing a sound to be on a client or server can effect the atmosphere/user interaction in a game.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage.Packages.Knit)

local SoundsService = Knit.CreateService {
    Name = "SoundsService",
    Client = {},
}

local SOUNDS = {
    --# { id, volume }
    AddedMoney = {'rbxassetid://307631257', .9},
    NotEnoughMoney = {'rbxassetid://654933750', .8},
    Purchased = {'rbxassetid://3020841054', .8},
    TimeTravel = {'rbxassetid://3101648169', .8},
}

--# Simple function to create/play a sound from a parent
function SoundsService:Play(soundName, parent)
    task.spawn(function()
        local soundData = SOUNDS[soundName]
        if not soundData then warn(`Could not find {soundName} in the list of sounds!`) return end
        local sound = Instance.new('Sound')
        sound.Parent = parent
        sound.SoundId = soundData[1]
        sound.Volume = soundData[2]
        sound.Looped = false
        sound:Play()
        sound.Ended:Wait()
        Debris:AddItem(sound, 0)
    end)
end

return SoundsService
