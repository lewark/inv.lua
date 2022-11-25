local Device = require 'inv.device.Device'

local ClientDevice = Device:subclass()

function ClientDevice:init(server, name, deviceType)
    ClientDevice.superClass.init(self, server, name, deviceType, {})
end

function ClientDevice:getID()
    return self.interface.getID()
end

function ClientDevice:getItemDetail(slot)
    error("getItemDetail not supported on ClientDevice")
end

return ClientDevice
