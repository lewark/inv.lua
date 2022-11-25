local ItemCriteria = require 'inv.ItemCriteria'

local RPCManager = {}

function RPCManager.listItems(server, clientID)
    local items = {}
    for k, item in pairs(server.invManager.items) do
        items[k] = item:serialize()
    end
    server:send(clientID, items)
end

function RPCManager.requestItem(server, clientID, clientName, itemName, count)
    local device = server.deviceManager.devices[clientName]
    print("request",device,clientName,server.deviceManager.devices)
    local crit = ItemCriteria({name=itemName, count=count})
    server:send(clientID, server.invManager:pushItemsTo(crit, device))
end

function RPCManager.storeItem(server, clientID, clientName, item, slot)
    local device = server.deviceManager.devices[clientName]
    print("store",device,clientName)
    server:send(clientID, server.invManager:pullItemsFrom(item, device, slot))
end

return RPCManager