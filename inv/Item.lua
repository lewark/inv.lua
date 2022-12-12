local Object = require 'object.Object'

-- Represents various types of items, including optional details such as name,
-- display name, and Ore Dictionary tags.
-- Used for both tracking counts of stored items and setting criteria for
-- operations such as crafting and item retrieval.
local Item = Object:subclass()

function Item:init(spec)
    -- string: The name (item ID) of the item, e.g. "minecraft:cobblestone".
    -- Optional.
    self.name = spec.name

    -- bool: Whether this Item contains complete information as reported by
    -- inventory.getItemDetail()
    self.detailed = spec.detailed or false
    -- string: The translated display name of the item, e.g. "Cobblestone".
    -- Optional.
    self.displayName = spec.displayName
    -- int: Maximum allowed count of the item within a stack (usually 64).
    -- Optional.
    self.maxCount = spec.maxCount

    -- table: Ore Dictionary tags attached to this item.
    -- Always present, but may be empty.
    self.tags = {}
    if spec.tags then
        if spec.tags[1] then
            -- convert an array of tags to the correct format
            for i, tag in ipairs(spec.tags) do
                self.tags[tag] = true
            end
        else
            self.tags = spec.tags
        end
    end

    -- int: The number of items in this item stack (default 1).
    self.count = 1
    if spec.count ~= nil then
        self.count = spec.count
    end
end

-- Returns true if the other item satisfies the criteria specified by this Item.
-- If a name is present on this item, the two must match.
-- Otherwise, at least one matching Ore Dictionary tag must be present on both.
function Item:matches(item)
    if self.name then
        return self.name == item.name
    end
    if item.tags then
        for tag, v in pairs(self.tags) do
            if item.tags[tag] then
                return true
            end
        end
    end
    return false
end

-- Returns true if the given item both matches the criteria as specified by Item:match,
-- and has a count greater than or equal to this item's count.
function Item:matchesCount(item, count)
    if not self:matches(item) then
        return false
    end
    if count == nil then
        count = item.count
    end
    return count >= self.count
end

-- Returns a copy of this Item.
function Item:copy()
    return Item(self)
end

-- Static method. Given an array of Items, combines any item stacks that match
-- each other into single stacks.
function Item.stack(items)
    local stacked = {}
    for slot, item in pairs(items) do
        local i = 1
        local didStack = false
        for i, item2 in ipairs(stacked) do
            if item:matches(item2) then
                item2.count = item2.count + item.count
                didStack = true
                break
            end
        end
        if not didStack then
            table.insert(stacked, item:copy())
        end
    end
    return stacked
end

-- Adds details to the Item as returned by inventory.getItemDetail()
function Item:setDetails(details)
    self.displayName = details.displayName
    self.maxCount = details.maxCount
    self.tags = details.tags or {}
    self.detailed = true
end

-- Returns a display name for the Item, falling back to Item.name if not present.
-- Currently unused.
function Item:getName()
    return self.displayName or self.name
end

-- Returns the Item's information as a plain table.
-- Used when sending item information to clients.
function Item:serialize()
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

return Item
