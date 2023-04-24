-- Timestamp // 02/01/2023 11:49:44 MNT
-- Author // @iohgoodness
-- Description // Controlling monetization on the server is super important
--// I normally keep it fairly simple, this being the main module with 2 other modules that hold tables for
--// Gamepasses and Developer Product purchases e.g { [purchaseId] = fn(player) --[[reward for player]] end }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local PurchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local MonetizationService = Knit.CreateService {
    Name = "MonetizationService",
    Client = {
        ActivateTimeTravel = Knit.CreateSignal(),
    },
}

function MonetizationService:KnitInit()
    self.GamepassParams = {}
    self.Gamepasses = require(ServerStorage['server-sync'].class.monetization.Gamepasses)
    self.DevProducts = require(ServerStorage['server-sync'].class.monetization.Devproducts)
end

function MonetizationService:KnitStart()
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(MonetizationService.OnPromptGamePassPurchaseFinished)
    MarketplaceService.ProcessReceipt = MonetizationService.ProcessReceipt
end

function MonetizationService.OnPromptGamePassPurchaseFinished(player, purchasedPassID, purchaseSuccess)
    if not purchaseSuccess then return end
    MonetizationService.Gamepasses[tostring(purchasedPassID)](player, MonetizationService.GamepassParams[player])
end

function MonetizationService.ProcessReceipt(receiptInfo)
    local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
    local purchased = false
    local success, errorMessage = pcall(function()
        purchased = PurchaseHistoryStore:GetAsync(playerProductKey)
    end)
    if success and purchased then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    elseif not success then
        error("Data store error:" .. errorMessage)
    end
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    local handler = MonetizationService.DevProducts[tostring(receiptInfo.ProductId)]
    local success, result = pcall(handler, receiptInfo, player)
    if not success or not result then
        warn("Error occurred while processing a product purchase")
        print("\nProductId:", receiptInfo.ProductId)
        print("\nPlayer:", player)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    local success, errorMessage = pcall(function()
        PurchaseHistoryStore:SetAsync(playerProductKey, true)
    end)
    if not success then
        error("Cannot save purchase data: " .. errorMessage)
    end
    return Enum.ProductPurchaseDecision.PurchaseGranted
end

function MonetizationService:Gamepass(player, id, params)
    local hasPass = false
    local success, message = pcall(function()
        hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
    end)
    if not success then
        warn("Error while checking if player has pass: " .. tostring(message))
        return
    end
    if not hasPass then
        self.GamepassParams[player] = params or {}
        MarketplaceService:PromptGamePassPurchase(player, id)
    end
end

function MonetizationService:Devproduct(player, id)
    MarketplaceService:PromptProductPurchase(player, id)
end

function MonetizationService:Incoming(player)
    self.GamepassParams[player] = {}
    for gamepassId,_ in pairs(MonetizationService.Gamepasses) do
        local hasPass = false
        local success, message = pcall(function()
            hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, tonumber(gamepassId))
        end)
        if not success then
            warn("Error while checking if player has pass: " .. tostring(message))
            return
        end
        if hasPass == true then
            MonetizationService.Gamepasses[tostring(gamepassId)](player)
        end
    end
end

function MonetizationService:Removing(player)
    self.GamepassParams[player] = nil
end

return MonetizationService