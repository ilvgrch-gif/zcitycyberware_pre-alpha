net.Receive("SellImplant", function(len, ply)
    local index = net.ReadUInt(8)
    local inv = PlayerInventory[ply:SteamID()] or {}
    local item = inv[index]
    if not item then
        ply:Notify("Invalid item.", 2)
        return
    end

    local price = 0
    if item.type == "implant" then
        price = IMPLANT_PRICES[item.id] or 100  -- если нет цены, продаём за 100
    else
        price = ORGAN_PRICES[item.id] or 80     -- для органов – фиксированная или 80 по умолчанию
    end

    table.remove(inv, index)
    PlayerInventory[ply:SteamID()] = inv
    net.Start("SyncInventory")
    net.WriteString(util.TableToJSON(inv))
    net.Send(ply)

    local wallet = tonumber(ply:GetNWString("WalletMoney") or "0") or 0
    ply:SetNWString("WalletMoney", tostring(wallet + price))
    ply:Notify("Sold " .. item.name .. " for $" .. price .. ".", 2)
end)

net.Receive("BlackMarketBuy", function(len, ply)
    print("SERVER: BlackMarketBuy from", ply:Nick())
    local class = net.ReadString()
    local name = net.ReadString()
    local price = net.ReadFloat()

    local wallet = tonumber(ply:GetNWString("WalletMoney") or "0") or 0
    if wallet < price then
        ply:Notify("Not enough money!", 2)
        return
    end
    ply:SetNWString("WalletMoney", tostring(wallet - price))

    AddToInventory(ply, {
        type = class:find("harvest_") and "organ" or "implant",
        id = class,
        name = name,
        timestamp = os.time()
    })
    ply:Notify("Purchased " .. name .. " – added to inventory.", 2)
end)

-- Инвентарь игроков (не затирать таблицу, если уже создана другим файлом)
PlayerInventory = PlayerInventory or {}

function AddToInventory(ply, item)
    local inv = PlayerInventory[ply:SteamID()] or {}
    table.insert(inv, item)
    PlayerInventory[ply:SteamID()] = inv
    net.Start("SyncInventory")
    net.WriteString(util.TableToJSON(inv))
    net.Send(ply)
end