local ItemCriteria = require 'inv.ItemCriteria'

local RPCMethods = {}

function RPCMethods.listItems(server, clientID)
    local items = {}
    for k, item in pairs(server.invManager.items) do
        items[k] = item:serialize()
    end
    server:send(clientID, items)
end

function RPCMethods.requestItem(server, clientID, clientName, itemName, count)
    local device = server.deviceManager.devices[clientName]
    print("request",device,clientName,server.deviceManager.devices)
    local crit = ItemCriteria({name=itemName, count=count})
    server:send(clientID, server.craftManager:pushOrCraftItemsTo(crit, device))
end

function RPCMethods.storeItem(server, clientID, clientName, item, slot)
    local device = server.deviceManager.devices[clientName]
    print("store",device,clientName)
    server:send(clientID, server.invManager:pullItemsFrom(item, device, slot))
end

function RPCMethods.register(server, clientID, clientName)
    server.clients[clientID] = clientName
end

function RPCMethods.unregister(server, clientID, clientName)
    server.clients[clientID] = nil
end

return RPCMethods
