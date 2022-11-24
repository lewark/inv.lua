local Object = require 'object.Object'
local ItemInfo = require 'inv.ItemInfo'

-- TODO: Maybe implement caching of item locations to speed up operations
--  on large storage networks?

local InvManager = Object:subclass()

function InvManager:init(server)
    self.server = server
    self.items = {}
    self.storage = {}
end

function InvManager:scanInventory(device)    
    local items = device.list()
    for slot, item in pairs(items) do
        self:updateDB(device, slot)
        items[item.name].count = items[item.name].count + item.count
    end
end

function InvManager:updateDB(device, slot)
    local item = device.getItemDetail(slot)
    if not self.items[item.name] then
        self.items[item.name] = Item(item.name, item)
    end
    if not self.items[item.name].detailed then
        self.items[item.name].setDetails(item)
    end
end

function InvManager:sortDevices()
    table.sort(self.storage, function(a,b) return (a.name < b.name) and not (a.priority < b.priority) end)
end

-- Returns a list of all items stored in the system
function InvManager:scanItems()
    for k, v in pairs(self.items) do
        v.count = 0
    end
    for i, device in ipairs(self.storage) do
        self:scanInventory(device)
    end
    return items
end

-- Attempts to push a given amount of items out from the system
-- destSlot is optional
function InvManager:pushItemsTo(searchItem,dest,destSlot)
    local count = 1
    if item.count ~= nil then
        count = item.count
    end
    for i, device in ipairs(self.storage) do
        local items = device.list()
        for slot, deviceItem in pairs(items) do
            local tryMove = false
            if searchItem.name and deviceItem.name == searchItem.name then
                tryMove = true
            elseif searchItem.tags then
                local details = device.getItemDetail(slot)
                for tag,v in pairs(searchItem.tags) do
                end
            end

            if tryMove then
                local toMove = math.min(item.count, count - moved)
                local n = device.pushItems(dest, slot, toMove, destSlot)
                moved = moved + n
                if moved >= count then
                    return moved
                end
            end
        end
    end
    return moved
end

-- Attempts to pull a given amount of items into the system
function InvManager:pullItemsFrom(src, srcSlot, count)
    local moved = 0
    self:updateDB(src, srcSlot)
    
    for i, device in ipairs(self.storage) do
        local toMove = count - moved
        local n = device.pullItems(src, srcSlot, toMove)
        moved = moved + n
        if count - moved <= 0 then
            return moved
        end
    end
    return moved
end

return InvManager
