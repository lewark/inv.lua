local Device = require 'inv.device.Device'
local Common = require 'inv.Common'
local Item = require 'inv.Item'

-- Represents an inventory connected to the network.
local Storage = Device:subclass()

function Storage:init(server, name, deviceType, config)
    Storage.superClass.init(self, server, name, deviceType, config)
    self.priority = self.config.priority or 0

    self.filters = nil
    if self.config.filters then
        self.filters = {}
        for i, filter in ipairs(self.config.filters) do
            table.insert(self.filters, Item(filter))
        end
    end

    self.server.invManager:addInventory(self)
end

function Storage:destroy()
    self.server.invManager:removeInventory(self)
end

-- Returns true if the item can be stored in this Storage according to
-- this device's configured item filters.
function Storage:itemAllowed(item)
    if self.filters then
        for i,filter in ipairs(self.filters) do
            if filter:matches(item) then
                return true
            end
        end
        return false
    end
    return true
end

-- Lists items contained in this Storage.
function Storage:list()
    return self.interface.list()
end

-- Pushes items from this Storage to another connected Device.
-- limit and toSlot are optional.
function Storage:pushItems(toDevice, fromSlot, limit, toSlot)
    return self.interface.pushItems(toDevice.location, fromSlot, limit, toSlot)
end

-- Pulls items into this Storage from another connected Device.
-- limit and toSlot are optional.
function Storage:pullItems(fromDevice, fromSlot, limit, toSlot)
    return self.interface.pullItems(fromDevice.location, fromSlot, limit, toSlot)
end

return Storage
