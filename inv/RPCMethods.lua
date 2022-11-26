local ItemCriteria = require 'inv.ItemCriteria'

local RPCMethods = {}

function RPCMethods.listItems(server, clientID, refresh)
    if refresh then
        server.invManager:scanInventories()
    end
    local items = {}
    for k, item in pairs(server.invManager.items) do
        items[k] = item:serialize()
    end
    server:send(clientID, {"items",items})
end

function RPCMethods.requestItem(server, clientID, clientName, itemName, count)
    local device = server.deviceManager.devices[clientName]
    local crit = ItemCriteria({name=itemName, count=count})
    server.craftManager:pushOrCraftItemsTo(crit, device)
end

function RPCMethods.storeItems(server, clientID, clientName, items)
    local device = server.deviceManager.devices[clientName]
    for slot, item in pairs(items) do
        server.invManager:pullItemsFrom(item, device, slot)
    end
end


function RPCMethods.unregister(server, clientID)
    server:unregister(clientID)
end

return RPCMethods
