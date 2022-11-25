local Object = require 'object.Object'

local ItemCriteria = Object:subclass()

function ItemCriteria:init(spec)
    self.name = spec.name
    self.tags = spec.tags
    self.count = 1
    if spec.count ~= nil then
        self.count = spec.count
    end
end

function ItemCriteria:matches(item)
    if self.name then
        return self.name == item.name
    end
    if self.tags and item.tags then
        for tag, v in pairs(self.tags) do
            if item.tags[tag] then
                return true
            end
        end
    end
    return false
end

function ItemCriteria:matchesCount(item, count)
    if not self:matches(item) then
        return false
    end
    if count == nil then
        count = item.count
    end
    return count >= self.count
end

return ItemCriteria