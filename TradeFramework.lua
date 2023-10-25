local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local TradeFramework = Knit.CreateService {
    Name = "TradeFramework";
    Client = {
        -- Creating signals for trade requests and manual trade closures
        sellrequest = Knit.CreateSignal(),
        manualclose = Knit.CreateSignal()
    };
}

-- Table to store active sale data
TradeFramework.activeSaleTable = {}

-- Event to handle player removal and clean up active trades related to that player
function TradeFramework:PlayerRemoving(player)
    -- If the player leaving is the one who initiated a trade
    for userId, trade in pairs(TradeFramework.activeSaleTable) do
        if trade.seller == player then
            local targetUser = game.Players:GetPlayerByUserId(userId)
            if targetUser then
                self.Client:DeclineTrade(targetUser)
            end
        end
    end
    
    -- If a trade is pending for the player who is leaving
    if TradeFramework.activeSaleTable[player.UserId] then
        local seller = TradeFramework.activeSaleTable[player.UserId].seller
        local itemName = TradeFramework.activeSaleTable[player.UserId].item.Name
        
        -- TODO: Check your game's item storage for item validity
        local itemTemplate = game.ServerStorage.Items:FindFirstChild(itemName)
        
        if itemTemplate and seller and seller.Backpack then
            local itemClone = itemTemplate:Clone()
            itemClone.Parent = seller.Backpack
        end

        TradeFramework.activeSaleTable[player.UserId] = nil
    end
end

-- Connect the PlayerRemoving event during the start phase of the service
function TradeFramework:KnitStart()
    game.Players.PlayerRemoving:Connect(function(player) 
        self:PlayerRemoving(player) 
    end)
end

-- Function to handle sell requests
function TradeFramework.Client:RequestSell(player, targetUser, price2, item)
    local price = math.abs(tonumber(price2))
    
    -- Basic validation checks for targetUser, price, and item
    if not targetUser or not price or not item or tonumber(price) == nil then
        return false
    end
    
    -- Check for invalid price values
    if price % 1 ~= 0 or price < 0 then
        return false
    end
    
    -- Check if the targetUser already has an incoming trade
    if TradeFramework.activeSaleTable[targetUser.UserId] then
        return false
    end
    
    -- TODO: Modify the line below to adjust the player's money value
    -- Ensure the player has enough money for the trade
    local playerMoneyValue = 0 -- TODO: Change this to wherever you hold the player's money value
    
    if playerMoneyValue < price then
        return false
    end

    -- Store the trade details in activeSaleTable
    TradeFramework.activeSaleTable[targetUser.UserId] = {
        seller = player,
        price = price,
        item = item,
        timestamp = os.time()
    }

    -- Fire the sell request to the client
    TradeFramework.Client.sellrequest:Fire(targetUser, item, player, price)
    
    -- Destroy the item from the seller
    item:Destroy()

    -- Start a timer to automatically decline the trade if no response is received within 15 seconds
    spawn(function()
        wait(15)
        local trade = TradeFramework.activeSaleTable[targetUser.UserId]
        if trade and os.difftime(os.time(), trade.timestamp) >= 15 then
            TradeFramework.Client.manualclose:Fire(targetUser)
        end
    end)

    return true
end

-- Function to handle trade acceptance
function TradeFramework.Client:AcceptTrade(targetUser)
    local trade = TradeFramework.activeSaleTable[targetUser.UserId]
    
    if trade then
        -- TODO: Adjust the player's money value here
        local targetUserMoneyValue = 0 -- Change this to wherever you hold the target user's money value
        
        if targetUserMoneyValue >= tonumber(trade.price) then
            -- Deduct the trade price from the target user's money
            targetUserMoneyValue = targetUserMoneyValue - trade.price
            
            local itemName = trade.item.Name
            -- TODO: Check your game's item storage for item validity
            local itemTemplate = game.ServerStorage.Items:FindFirstChild(itemName)
            
            if itemTemplate then
                local itemClone = itemTemplate:Clone()
                itemClone.Parent = targetUser.Backpack

                local player = game.Players:FindFirstChild(trade.seller.Name)
                
                if player then
                    -- TODO: Adjust the seller's money value here
                    local sellerMoneyValue = 0 -- Change this to wherever you hold the seller's money value
                    sellerMoneyValue = sellerMoneyValue + trade.price
                end

                TradeFramework.activeSaleTable[targetUser.UserId] = nil
                return true
            end
        end
    end
    
    TradeFramework.activeSaleTable[targetUser.UserId] = nil
end

-- Function to handle trade declination
function TradeFramework.Client:DeclineTrade(targetUser)
    local trade = TradeFramework.activeSaleTable[targetUser.UserId]
    
    if trade then
        local itemName = trade.item.Name
        
        -- TODO: Check your game's item storage for item validity
        local itemTemplate = game.ServerStorage.Items:FindFirstChild(itemName)
        
        if itemTemplate then
            local player = game.Players:FindFirstChild(trade.seller.Name)
            
            if player and player.Backpack then
                local itemClone = itemTemplate:Clone()
                itemClone.Parent = player.Backpack
            end
        end
        
        TradeFramework.activeSaleTable[targetUser.UserId] = nil
        return true
    end
end

return TradeFramework
