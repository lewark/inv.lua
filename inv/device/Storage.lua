local Device = require 'inv.device.Device'
local Common = require 'inv.Common'
local Item = require 'inv.Item'

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

function Storage:list()
    return self.interface.list()
end

function Storage:pushItems(toDevice, fromSlot, limit, toSlot)
    return self.interface.pushItems(toDevice.location, fromSlot, limit, toSlot)
end

function Storage:pullItems(fromDevice, fromSlot, limit, toSlot)
    return self.interface.pullItems(fromDevice.location, fromSlot, limit, toSlot)
end

return Storage
