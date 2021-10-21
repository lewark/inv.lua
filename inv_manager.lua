local p = peripheral.getNames()

local function itemCreate(name,count)
    return {
        name=name,
        count=count
    }
end

local function detailsCreate(details)
    local d = {
        displayName=details.displayName,
        maxCount=details.maxCount,
        tags=(details.tags or {})
    }
    return d
end

InvManager = {}

function InvManager:new()    
    return setmetatable({itemDB={}},{__index=self})
end

function InvManager:scanInventory(invName, inv, items)    
    local inv_items = inv.list()
    for slot,item in pairs(inv_items) do
        if not items[item.name] then
            items[item.name] = itemCreate(item.name,0)
        end
        items[item.name].count = items[item.name].count + item.count
        self:updateDB(inv,slot,item)
    end
end

function InvManager:updateDB(inv,slot,item)
    if not self.itemDB[item.name] then
        local details = inv.getItemDetail(slot)
        print("made entry for"..item.name)
        self.itemDB[item.name] = detailsCreate(details)
    end
end

function InvManager:getInventories()
    local invs = {}
    for i,name in pairs(peripheral.getNames()) do
        local inv = peripheral.wrap(name)
        if inv.list then
            invs[name] = inv
        end
    end
    return invs
end

-- Returns a list of all items stored in the system
function InvManager:scanItems()
    items = {}
    for name,inventory in pairs(self:getInventories()) do
        self:scanInventory(name,inventory,items)
    end
    return items
end

-- Attempts to pull a given amount of items from the system
-- destSlot is optional
function InvManager:pullItemsExt(name,count,dest,destSlot)
    local moved = 0
    for invName,inv in pairs(self:getInventories()) do
        local items = inv.list()
        for slot,item in pairs(items) do
            if item.name == name then
                local toMove = math.min(item.count,count - moved)
                local n = inv.pushItems(dest, slot, toMove, destSlot)
                moved = moved + n
                if count - moved <= 0 then
                    return moved
                end
            end
        end
    end
    return moved
end

function InvManager:pullItemsByTag(tag,count,dest,destSlot)
    local moved = 0
    for invName,inv in pairs(self:getInventories()) do
        local items = inv.list()
        for slot,item in pairs(items) do
            self:updateDB(inv,slot,item)
            if self.itemDB[item.name].tags[tag] then
                local toMove = math.min(item.count,count - moved)
                local n = inv.pushItems(dest, slot, toMove, destSlot)
                moved = moved + n
                if count - moved <= 0 then
                    return moved
                end
            end
        end
    end
    return moved
end

--[[
function InvManager:countItems(name)
    local count = 0
    for invName,inv in pairs(self:getInventories()) do
        local items = inv.list()
        for slot,item in pairs(items) do
            if item.name == name then
                count = count + item.count
            end
        end
    end
    return count
end

function InvManager:countItemsByTag(tag)
    local count = 0
    for invName,inv in pairs(self:getInventories()) do
        local items = inv.list()
        for slot,item in pairs(items) do
            self:updateDB(inv,slot,item)
            if self.itemDB[item].tags[tag] then
                count = count + item.count
            end
        end
    end
    return count
end
--]]

-- Attempts to push a given amount of items into the system
function InvManager:pushItemsExt(count,src,srcSlot)
    local moved = 0
    --local srcInv = peripheral.wrap(src)
    --local srcDetail = src.getItemDetail(srcSlot)
    
    for invName,inv in pairs(self:getInventories()) do
        local toMove = count - moved
        local n = inv.pullItems(src, srcSlot, toMove)
        moved = moved + n
        if count - moved <= 0 then
            return moved
        end
    end
    return moved
end

