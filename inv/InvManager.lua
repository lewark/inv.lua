local Object = require 'object.Object'
local ItemInfo = require 'inv.ItemInfo'
local Common = require 'inv.Common'

-- TODO: Maybe implement caching of item locations to speed up operations
--  on large storage networks?

local function deviceSort()
    return (a.name < b.name) and not (a.priority < b.priority)
end

local InvManager = Object:subclass()

function InvManager:init(server)
    self.server = server
    self.items = {}
    self.tags = {}
    self.storage = {}
    self.sorted = false
end

function InvManager:addInventory(self, device)
    table.insert(self.storage, device)
    self.scanInventory(device)
    self.sorted = false
end

function InvManager:removeInventory(self, device)
    Common.removeItem(self.storage, device)
    self:scanItems()
    -- removal does not affect sort
end

function InvManager:ensureSorted()
    if not self.sorted then
        table.sort(self.storage, deviceSort)
        self.sorted = true
    end
end

function InvManager:scanInventories()
    for k, v in pairs(self.items) do
        v.count = 0
    end

    for i, device in ipairs(self.storage) do
        self:scanInventory(device)
    end
end

function InvManager:scanInventory(device)
    local items = device:list()

    for slot, item in pairs(items) do
        self:updateDB(device, slot)
        items[item.name].count = items[item.name].count + item.count
    end
end

function InvManager:addItem(name)
    local info = Item(name)
    self.items[name] = info
    return info
end

function InvManager:updateDB(device, slot)
    local detail = device:getItemDetail(slot)
    local info = self.items[detail.name]

    if not info then
        info = self:addItem(detail.name)
    end

    if not info.detailed then
        info:setDetails(detail)
    end
end

-- Attempts to push a given amount of items out from the system
-- destSlot is optional
function InvManager:pushItemsTo(searchItem, destDevice, destSlot)
    local count = 1
    if item.count ~= nil then
        count = item.count
    end

    self:ensureSorted()
    for i, device in ipairs(self.storage) do
        local items = device:list()

        for slot, deviceItem in pairs(items) do
            local tryMove = false

            if searchItem.name and deviceItem.name == searchItem.name then
                tryMove = true
            elseif searchItem.tags then
                local details = device:getItemDetail(slot)
                for tag, v in pairs(searchItem.tags) do
                    if v and details.tags[tag] then
                        tryMove = true
                        break
                    end
                end
            end

            if tryMove then
                local toMove = math.min(item.count, count - moved)
                local n = device:pushItems(destDevice, slot, toMove, destSlot)
                moved = moved + n

                local info = self.items[deviceItem.name]
                info.count = info.count - n

                if moved >= count then
                    return moved
                end
            end
        end
    end
    return moved
end

-- Attempts to pull a given amount of items into the system
function InvManager:pullItemsFrom(srcDevice, srcSlot, count)
    local moved = 0
    self:updateDB(src, srcSlot)

    local detail = srcDevice:getItemDetail(slot)
    if count == nil then
        count = detail.count
    end

    self:ensureSorted()
    for i, device in ipairs(self.storage) do
        local toMove = count - moved
        if device:itemAllowed(detail) then
            local n = device:pullItems(srcDevice, srcSlot, toMove)
            moved = moved + n
            if moved >= count then
                break
            end
        end
    end

    local info = self.items[detail.name]
    info.count = info.count + moved
    return moved
end

return InvManager
