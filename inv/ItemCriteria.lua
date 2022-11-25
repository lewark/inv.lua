local Object = require 'object.Object'

local ItemCriteria = Object:subclass()

local ItemCriteria:init(spec)
    self.name = spec.name
    self.tag = spec.tag
    self.count = 1
    if spec.count ~= nil then
        self.count = spec.count
    end
end

local ItemCriteria:matches(item)
    if self.name then
        return self.name == item.name
    end
    if self.tag and item.tags then
        return item.tags[tag]
    end
    return false
end

local ItemCriteria:matchesCount(item, count)
    if not self:matches(item) then
        return false
    end
    if count == nil then
        count = item.count
    end
    return count >= self.count
end

return ItemCriteria