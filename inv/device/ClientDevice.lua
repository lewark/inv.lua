local Device = require 'inv.device.Device'

local ClientDevice = Device:subclass()

function ClientDevice:init(server, name, deviceType)
    ClientDevice.superClass.init(self, server, name, deviceType)
end

function getID()
    return self.interface.getID()
end

return Device
