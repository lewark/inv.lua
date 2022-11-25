local Device = require 'inv.device.Device'
local Common = require 'inv.Common'
local ItemCriteria = require 'inv.ItemCriteria'

local Storage = Device:subclass()

function Storage:init(server, name, deviceType, config)
    Storage.superClass.init(self, server, name, deviceType, config)
    self.priority = self.config.priority or 0
    self.filter = nil
    if self.config.filter then
        self.filter = ItemCriteria(self.config.filter)
    end

    self.server.invManager:addInventory(self)
end

function Storage:destroy()
    self.server.invManager:removeInventory(self)
end

function Storage:itemAllowed(item)
    return not self.filter or self.filter:matches(item)
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
