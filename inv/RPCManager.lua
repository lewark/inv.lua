local RPCManager = {}

function RPCManager.listItems(server, clientID)
    local items = {}
    for k, item in pairs(self.server.invManager.items) do
        items[k] = item:serialize()
    end
    server:send(clientID, items)
end

return RPCManager