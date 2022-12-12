local Object = require 'object.Object'
local Item = require 'inv.Item'
local Common = require 'inv.Common'

-- Manages network inventories and item storage/retrieval.
local InvManager = Object:subclass()

function InvManager:init(server)
    self.server = server
    -- table<string, Item>: The items stored in this network.
    -- Indexed by name of the item.
    self.items = {}
    -- table<string, table<string, Item>>: All items associated with each Ore
    -- Dictionary tag previously seen on this network.
    self.tags = {}
    -- table<int, Storage>: The inventories connected to this network.
    self.storage = {}
    -- bool: Whether the storage list is currently sorted.
    self.sorted = false

    -- bool: Whether the current state of the stored items has been updated.
    -- If true, then the changes need to be synchronized to the clients.
    self.updated = false
    -- table<string, bool>: Items that have changed since the last client sync.
    self.updatedItems = {}
end

-- Adds an inventory to the network, updating the network state as necessary.
function InvManager:addInventory(device)
    table.insert(self.storage, device)
    self:scanInventory(device)
    self.sorted = false
end

-- Removes an inventory from the network, updating the network state as necessary.
function InvManager:removeInventory(device)
    Common.removeItem(self.storage, device)
    self:scanInventories()
    -- removal does not affect sort
end

-- Static comparison method that returns true if inventory a should be sorted
-- before inventory b.
function InvManager.deviceSort(a, b)
    if a.priority ~= b.priority then
        return a.priority > b.priority
    end
    return (a.name < b.name)
end

-- Sorts the list of connected inventories if necessary.
function InvManager:ensureSorted()
    if not self.sorted then
        table.sort(self.storage, self.deviceSort)
        self.sorted = true
    end
end

-- Scans all connected inventories, adding their stored items to the database.
-- Resets any preexisting item counts to 0 beforehand.
function InvManager:scanInventories()
    for k, v in pairs(self.items) do
        v.count = 0
    end

    for i, device in ipairs(self.storage) do
        self:scanInventory(device)
    end
end

-- Scans a connected inventory and adds its stored items to the database.
function InvManager:scanInventory(device)
    local items = device:list()

    for slot, item in pairs(items) do
        local entry = self.items[item.name]
        if not entry or not entry.detailed then
            local detail = device:getItemDetail(slot)
            self:updateDB(detail)
        end
        self.items[item.name].count = self.items[item.name].count + item.count
    end
end

-- Given an item name, adds a new item to the database.
function InvManager:addItem(name)
    local info = Item{name=name, count=0}
    self.items[name] = info
    return info
end

-- Given a detail specification for an item, adds or updates the associated
-- item in the database if necessary.
function InvManager:updateDB(detail)
    local info = self.items[detail.name]

    if not info then
        info = self:addItem(detail.name)
    end

    if not info.detailed then
        info:setDetails(detail)
        self:updateTags(info.name)
    end
end

-- Files the item under its given tags.
function InvManager:updateTags(name)
    local info = self.items[name]
    for tag, v in pairs(info.tags) do
        local entries = self.tags[tag]
        if not entries then
            entries = {}
            self.tags[tag] = entries
        end
        entries[name] = info
    end
end

-- Given a list of items to find, returns a list of requested items that are
-- not stored in the network.
-- todo: improve this
function InvManager:tryMatchAll(searchItems)
    local s = Item.stack(searchItems)
    for name, item in pairs(self.items) do
        local n = item.count

        local i = 1
        while i <= #s do
            local searchItem = s[i]
            -- TODO: is this check necessary now that Item.stack is used?
            if searchItem:matchesCount(item,n) then
                n = n - searchItem.count
                table.remove(s, i)
            else
                i = i + 1
            end
        end
    end
    return s
end

-- Returns a list of all known item types matching the given specification.
function InvManager:resolveCriteria(criteria)
    local result = {}
    if criteria.name then
        result[criteria.name] = true
    elseif criteria.tags then
        for tag, v in pairs(criteria.tags) do
            local entries = self.tags[tag]
            if entries then
                for name, item in pairs(entries) do
                    result[name] = true
                end
            end
        end
    end
    return result
end

-- Attempts to push a given amount of items out from the system.
-- destSlot is optional.
function InvManager:pushItemsTo(criteria, destDevice, destSlot)
    local moved = 0
    local matches = self:resolveCriteria(criteria)

    self:ensureSorted()
    for i, device in ipairs(self.storage) do
        local items = device:list()

        for slot, deviceItem in pairs(items) do
            if matches[deviceItem.name] then
                local toMove = math.min(deviceItem.count, criteria.count - moved)
                local n = device:pushItems(destDevice, slot, toMove, destSlot)

                if n > 0 then
                    moved = moved + n

                    local info = self.items[deviceItem.name]
                    info.count = info.count - n

                    self.updated = true
                    self.updatedItems[deviceItem.name] = true
                end

                if moved >= criteria.count then
                    return moved
                end
            end
        end
    end

    return moved
end

-- Attempts to pull a given amount of items into the system.
function InvManager:pullItemsFrom(item, srcDevice, srcSlot)
    local moved = 0
    self:updateDB(item) -- ensure we know what we're adding to the system

    self:ensureSorted()
    for i, device in ipairs(self.storage) do
        local toMove = item.count - moved
        if device:itemAllowed(item) then
            local n = device:pullItems(srcDevice, srcSlot, toMove)
            moved = moved + n
            if moved >= item.count then
                break
            end
        end
    end

    if moved > 0 then
        local info = self.items[item.name]
        info.count = info.count + moved

        self.updatedItems[item.name] = true
        self.updated = true
    end

    return moved
end

-- Returns a list of items changed since the last client sync,
-- with all items serialized to the proper client format.
function InvManager:getUpdatedItems()
    if self.updated then
        local u = {}
        for name, v in pairs(self.updatedItems) do
            u[name] = self.items[name]:serialize()
        end
        self.updated = false
        self.updatedItems = {}
        return u
    end
    return nil
end

return InvManager
