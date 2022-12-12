local Device = require 'inv.device.Device'

-- Represents a client turtle connected to the network.
local ClientDevice = Device:subclass()

function ClientDevice:init(server, name, deviceType)
    ClientDevice.superClass.init(self, server, name, deviceType, {})
end

-- Returns this client's computer ID. Currently unused.
function ClientDevice:getID()
    return self.interface.getID()
end

function ClientDevice:getItemDetail(slot)
    error("getItemDetail not supported on ClientDevice")
end

return ClientDevice
