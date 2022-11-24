local Object = require 'object.Object'

local Device = Object:subclass()

function Device:init(server, name, deviceType)
    self.server = server
    self.name = name
    self.interface = nil
    self.types = {}
    self.type = deviceType
    self.config = {}
    if self.name then
        self.interface = peripheral.wrap(self.name)
        self.config = self.server.deviceManager.getConfig(self)
    end
end

function Device:destroy() end

return Device
