local Object = require 'object.Object'

-- Represents a network-attached device, and
-- acts as a proxy for CC peripheral methods.
local Device = Object:subclass()

function Device:init(server, name, deviceType, config)
    self.server = server
    -- string: The name of the device, e.g. "minecraft:chest_1"
    self.name = name
    -- string: The location that the device actually occupies on the network,
    -- and the destination that items are sent to.
    -- Equals name in most cases, but differs for Workbench peripherals.
    self.location = name
    -- table: The peripheral interface for this Device
    -- as returned by peripheral.wrap().
    self.interface = nil
    -- string: The type of this Device, e.g. "minecraft:chest"
    self.type = deviceType
    -- table: Configuration for this Device as specified in server.json.
    self.config = config

    if self.name then
        self.interface = peripheral.wrap(self.name)
    end
end

-- Returns a detailed description of items in the given slot.
-- May cause an error if not supported by the target Device.
function Device:getItemDetail(slot)
    return self.interface.getItemDetail(slot)
end

-- Destroys this device, cleaning up any attached state.
function Device:destroy() end

return Device
