local Object = require 'object.Object'

local Device = Object:subclass()

function Device:init(system, name, deviceType)
    self.system = system
    self.name = name
    self.interface = nil
    self.types = {}
    self.type = deviceType
    self.config = {}
    if self.name then
        self.interface = peripheral.wrap(self.name)
        self.config = self.system.getConfig(self.name, self.type)
    end
end

function Device:destroy() end

return Device
