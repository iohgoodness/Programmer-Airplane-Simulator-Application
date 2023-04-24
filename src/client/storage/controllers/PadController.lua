-- Timestamp // 02/01/2023 10:01:57 MNT
-- Author // @iohgoodness
-- Description // Giving a nice animation to the objects that a player spawns in
--// It is fairly boring to just change the parent, so tweening helps make things feel more interactive, like a player's money truly went towards something

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PadController = Knit.CreateController { Name = "PadController" }

local Tween = Knit.common.Interface.Tween

local ZERO_VECTOR = Vector3.new()
local ZERO_UDIM2  = UDim2.fromScale()

function PadController:KnitStart()
    local PadService = Knit.GetService("PadService")
    PadService.NewModel:Connect(function(model, padModel)
        local partData = {}
        for _,part in pairs(model:GetDescendants()) do
            if not part:IsA('BasePart') then continue end
            local cf, size = part.CFrame, part.Size
            partData[part] = {cf, size}
            part.CFrame = cf * CFrame.new(Vector3.new(math.random(-10, 10),math.random(-10, 10),math.random(-10, 10))) * CFrame.Angles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360)))
            part.Size = ZERO_VECTOR
        end
        for part,data in pairs(partData) do
            part.Parent = workspace
            Tween(part, {CFrame = data[1]}, 1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Tween(part, {Size = data[2]}, 1.21, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        end
        local padParts,padBeams = {},{}
        for _,object in pairs(padModel:GetDescendants()) do
            if object:IsA('BasePart') then
                table.insert(padParts, object)
            elseif object:IsA('Beam') then
                table.insert(padBeams, object)
            end
        end
        for _,part in pairs(padParts) do
            Tween(part, {Size = ZERO_VECTOR}, 1.21, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        end
        for _,beam in pairs(padBeams) do
            beam.Transparency = NumberSequence.new(1)
        end
        Tween(padModel.BillboardGui, {Size = ZERO_UDIM2}, 1.21)
        task.wait(1.4)
        PadService.ClientFinishAnim:Fire()
    end)
end

return PadController
