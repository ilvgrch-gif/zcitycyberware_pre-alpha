-- Файл: cl_inventory_sync.lua
-- Отвечает только за получение инвентаря с сервера и сохранение в LocalPlayer().Inventory

-- Получение инвентаря от сервера
net.Receive("SyncInventory", function()
    local ply = LocalPlayer()
    local json = net.ReadString()
    if json and json ~= "" then
        ply.Inventory = util.JSONToTable(json)
        print("[Inventory] Synced " .. #ply.Inventory .. " items")
    else
        ply.Inventory = {}
    end
end)

-- Запрос инвентаря при появлении игрока
hook.Add("PlayerSpawn", "RequestInventory", function(ply)
    if ply ~= LocalPlayer() then return end
    net.Start("RequestInventory")
    net.SendToServer()
end)

-- На всякий случай: запросить инвентарь сразу после загрузки клиента (если PlayerSpawn уже прошёл)
timer.Simple(0.5, function()
    if IsValid(LocalPlayer()) then
        net.Start("RequestInventory")
        net.SendToServer()
    end
end)

print("cl_inventory_sync loaded")