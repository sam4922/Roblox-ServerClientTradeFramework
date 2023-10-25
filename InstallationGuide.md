# Roblox Trade Framework Installation Guide

Welcome to the Roblox Trade Framework installation guide. This framework, built on top of the [KNIT framework](https://knit.roblox.com/), offers a robust and efficient trading system for your Roblox game. Before proceeding, understand that this guide is intended to help you connect the server to the client. It's not meant to be a complete copy-and-paste solution; specific areas require adjustments based on your game's unique architecture.

## Step 1: Setup

1. If you haven't already, first install the [KNIT framework](https://sleitnick.github.io/Knit/). It's essential to familiarize yourself with its documentation to understand its structure and capabilities.
2. Place the `TradeFramework` module script inside the `Services` folder of your game.

## Step 2: Required Customization

### Player Money Value:

Inside the `TradeFramework` script, you'll find comments labeled `TODO`. These guide you to the sections where you need to:

1. Adjust the retrieval of the player's money value based on where you store this value in your game.
2. Validate items. Adjust this section to check within your game's `ServerStorage` or wherever you store valid in-game items.

## Step 3: Client-Side Setup

For a UI button in your game to interact with our trading framework:

1. Create a UI button on the client side of your game.
2. Attach a `LocalScript` to this button. 
3. In this `LocalScript`, set up event listeners for the `sellrequest` and `manualclose` signals.
4. Set up the button's `MouseButton1Click` event to fire the server-side functions.

```lua
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local TradeFramework = Knit.GetService("TradeFramework")

-- Listening to server events
TradeFramework.Client.sellrequest:Connect(function(item, player, price)
    -- Handle the incoming sell request, e.g., displaying a UI prompt
end)

TradeFramework.Client.manualclose:Connect(function()
    -- Handle the manual trade closure, e.g., hiding a prompt or displaying a message
end)

-- Assuming your button is named "TradeButton"
local button = script.Parent.TradeButton

button.MouseButton1Click:Connect(function()
    -- Collect details like target user, price, and item. This example uses placeholders.
    local targetUser = game.Players:FindFirstChild("TargetUsername")
    local price = 100
    local item = game.ServerStorage.Items:FindFirstChild("ItemName")

    -- Fire the RequestSell function
    TradeFramework.Client:RequestSell(game.Players.LocalPlayer, targetUser, price, item)
end)
```
**Note, This is just an outline and a rough example of how to set up client side**
