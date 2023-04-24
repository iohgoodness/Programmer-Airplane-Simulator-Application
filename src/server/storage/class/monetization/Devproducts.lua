
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return {
    ['000000000'] = function(receipt, player)
        -- common devproduct: add $1000 to the player here
        return true
    end,
}