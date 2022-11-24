local Object = require 'object.Object'

local ItemInfo = Object:subclass()

-- Assumptions made here:
-- Items of an ID always have the same name, tags, and maximum count
-- This is not true for display names! (See CC computers)
-- TODO: Do this better
function ItemInfo:init(name)
    self.name = name
    self.count = 0
    
    self.displayName = nil
    self.maxCount = nil
    self.tags = nil
    self.detailed = false
end

function ItemInfo:setDetails(details)
    self.displayName = details.displayName
    self.maxCount = details.maxCount
    self.tags = details.tags or {}
    self.detailed = true
end

function ItemInfo:getName()
    return self.displayName or self.name
end

function ItemInfo:serialize()
    local t = {}
    t.name = self.name
    t.count = self.count
    if self.detailed then
        t.displayName = self.displayName
        t.maxCount = self.maxCount
        t.tags = self.tags
    else
        t.displayName = self.name
    end
    return t
end

return ItemInfo
