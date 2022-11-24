local Device = require 'inv.device.Device'
local Common = require 'inv.Common'

local Storage = Device:subclass()

function Storage:init(server, name, deviceType, config)
    Storage.superClass.init(self, server, name, deviceType, config)
    self.priority = self.config.priority or 0
    self.filter = self.config.filter

    self.server.invManager:addInventory(self)
end

function Storage:destroy()
    self.server.invManager:removeInventory(self)
end

function Storage:itemAllowed(item)
    if not self.filter then
        return true
    end
    if self.filter.name and self.filter.name[item.name] then
        return true
    end
    if self.filter.tag and item.tags then
        for tag, v in pairs(self.filter.tags) do
            if item.tags[tag] and v then
                return true
            end
        end
    end
    return false
end

function Storage:list()
    return self.interface.list()
end

function Storage:pushItems(toDevice, fromSlot, limit, toSlot)
    return self.interface.pushItems(toDevice.name, fromSlot, limit, toSlot)
end

function Storage:pullItems(fromDevice, fromSlot, limit, toSlot)
    return self.interface.pullItems(fromDevice.name, fromSlot, limit, toSlot)
end

return Storage
