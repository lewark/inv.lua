local Object = require 'object.Object'
local ItemInfo = require 'inv.ItemInfo'
local Common = require 'inv.Common'

-- TODO: Maybe implement caching of item locations to speed up operations
--  on large storage networks?

local function deviceSort(a, b)
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

function InvManager:addInventory(device)
    table.insert(self.storage, device)
    self:scanInventory(device)
    self.sorted = false
end

function InvManager:removeInventory(device)
    Common.removeItem(self.storage, device)
    self:scanInventories()
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
    --print("scanInventory")

    for slot, item in pairs(items) do
        local detail = device:getItemDetail(slot)
        self:updateDB(detail)
        self.items[item.name].count = self.items[item.name].count + item.count
    end
end

function InvManager:addItem(name)
    local info = ItemInfo(name)
    self.items[name] = info
    return info
end

function InvManager:updateDB(detail)
    local info = self.items[detail.name]

    if not info then
        info = self:addItem(detail.name)
    end

    if not info.detailed then
        info:setDetails(detail)
    end
end

function InvManager:tryMatchAll(searchItems)
    local s = Common.shallowCopy(searchItems)
    for name, item in pairs(self.items) do
        local n = item.count
        
        local i = 1
        while i <= #s do
            local searchItem = s[i]
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

-- Attempts to push a given amount of items out from the system
-- destSlot is optional
function InvManager:pushItemsTo(criteria, destDevice, destSlot)
    local moved = 0

    self:ensureSorted()
    for i, device in ipairs(self.storage) do
        local items = device:list()

        for slot, deviceItem in pairs(items) do
            if criteria:matches(deviceItem) then
                local toMove = math.min(deviceItem.count, criteria.count - moved)
                local n = device:pushItems(destDevice, slot, toMove, destSlot)
                moved = moved + n

                local info = self.items[deviceItem.name]
                info.count = info.count - n

                if moved >= criteria.count then
                    return moved
                end
            end
        end
    end

    return moved
end

-- Attempts to pull a given amount of items into the system
function InvManager:pullItemsFrom(item, srcDevice, srcSlot)
    local moved = 0
    self:updateDB(item)

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

    local info = self.items[item.name]
    info.count = info.count + moved

    return moved
end

return InvManager
