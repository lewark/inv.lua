local Object = require 'object.Object'

local Device = Object:subclass()

function Device:init(server, name, deviceType, config)
    self.server = server
    self.name = name
    self.interface = nil
    self.types = {}
    self.type = deviceType
    self.config = config
    if self.name then
        self.interface = peripheral.wrap(self.name)
    end
end

function Device:getItemDetail(slot)
    return self.interface.getItemDetail(slot)
end

function Device:destroy() end

return Device
