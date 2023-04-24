-- Timestamp // 01/27/2023 12:53:29 MNT
-- Author // @iohgoodness
-- Description // Paycheck UI + screen for paychecks
--// Using Knit, we listen to the service signal/remote for a value update of money
--// Updating all of the "screens" that the server is tells us to

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PaycheckController = Knit.CreateController { Name = "PaycheckController" }

local ConvertToCommas = Knit.common.Math.ConvertToCommas

--# Instead of just flat changing the numbers, we give an quick increment effect
function PaycheckController:KnitStart()
    local PaycheckService = Knit.GetService("PaycheckService")
    PaycheckService.UpdateScreens:Connect(function(textLabels, value, change)
        for _,textLabel in pairs(textLabels) do
            task.spawn(function()
                if change > 0 then
                    local divisor = 11
                    local waitTime = .001
                    local increment = math.ceil(change / divisor)
                    for i=value-change, value, increment do
                        textLabel.Text = `${ConvertToCommas(i)}`
                        task.wait(waitTime)
                    end
                end
                textLabel.Text = `${ConvertToCommas(value)}`
            end)
        end
    end)
end

return PaycheckController
