local Device = require 'Device'

local Storage = Device:subclass()

function Storage:init(system, name)
    Storage.superClass.init(self, system, name)
    self.priority = self.config.priority or 0
    self.filter = self.config.filter
end

function Storage:itemAllowed(item)
    if not self.filter then
        return true
    end
    if self.filter.name and self.filter.name[item.name] then
        return true
    end
    if self.filter.tag and item.tags then
        for k,tag in pairs(item.tags) do
            if self.filter.tag[tag] then
                return true
            end
        end
    end
    return false
end

return Storage