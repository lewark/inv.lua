local Client = require 'inv.Client'

local args = {...}
if #args < 1 then
    print("Usage: run_client SERVER_ID")
    return
end

local serverID = tonumber(args[1])
print(serverID)

local client = Client(serverID)
print(client)
client:mainLoop()
