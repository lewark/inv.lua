local Object = require 'object.Object'

-- TODO: Maybe implement caching of item locations to speed up operations
--  on large storage networks?

local InvManager = Object:subclass()

function InvManager:init(overrides)
    self.itemDB = {}
    self.type_overrides = {}
    self.name_overrides = {}
    
    for _,v in pairs(overrides) do
        if v.type then
            mgr.type_overrides[v.type] = v
        elseif v.name then
            mgr.name_overrides[v.name] = v
        end
    end

    return setmetatable(mgr,{__index=self})
end

function InvManager:itemCreate(name,count)
    local i = {
        name=name,
        count=count,
        displayName=name
    }
    print("scanning "..name)
    for k,v in pairs(self.itemDB) do
        print(k .. v.displayName)
    end
    if self.itemDB[name] then
        i.displayName = self.itemDB[name].displayName
        print("found")
    else
        print("not found")
    end
    return i
end

-- Assumptions made here:
-- Items of an ID always have the same name, tags, and maximum count
-- This is not true for display names! (See CC computers)
-- TODO: Do this better
function InvManager:detailsCreate(details)
    local d = {
        displayName=details.displayName,
        maxCount=details.maxCount,
        tags=(details.tags or {})
    }
    return d
end

function InvManager:scanInventory(invName, inv, items)    
    local inv_items = inv.list()
    for slot,item in pairs(inv_items) do
        self:updateDB(inv,slot,item)
        if not items[item.name] then
            items[item.name] = self:itemCreate(item.name,0)
        end
        items[item.name].count = items[item.name].count + item.count
    end
end

function InvManager:updateDB(inv,slot,item)
    if not self.itemDB[item.name] then
        local details = inv.getItemDetail(slot)
        --print("made entry for "..item.name)
        self.itemDB[item.name] = self:detailsCreate(details)
    end
end

function InvManager:getPriority(inv)
    if self.name_overrides[inv.name] and self.name_overrides[inv.name].priority then
        return self.name_overrides[inv.name].priority
    elseif self.type_overrides[inv.type] and self.type_overrides[inv.type].priority then
        return self.type_overrides[inv.type].priority
    end
    return 0
end

function InvManager:getInventories()
    local invs = {}
    for i,name in pairs(peripheral.getNames()) do
        local inv = peripheral.wrap(name)
        if inv.list then
            table.insert(invs,{name=name,inv=inv,type=peripheral.getType(name)})
        end
    end
    table.sort(invs, function(a,b) return (a.name < b.name) and not (self:getPriority(a) < self:getPriority(b)) end)
    return invs
end

-- Returns a list of all items stored in the system
function InvManager:scanItems()
    items = {}
    for i,inventory in ipairs(self:getInventories()) do
        self:scanInventory(inventory.name,inventory.inv,items)
    end
    return items
end

-- Attempts to pull a given amount of items from the system
-- destSlot is optional
function InvManager:pullItemsExt(name,count,dest,destSlot)
    local moved = 0
    for i,inventory in ipairs(self:getInventories()) do
        local inv = inventory.inv
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

-- TODO: this is duplicated, might want to use a lambda function or something
function InvManager:pullItemsByTag(tag,count,dest,destSlot)
    local moved = 0
    for i,inventory in ipairs(self:getInventories()) do
        local inv = inventory.inv
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
    
    for i,inventory in ipairs(self:getInventories()) do
        local inv = inventory.inv
        local toMove = count - moved
        local n = inv.pullItems(src, srcSlot, toMove)
        moved = moved + n
        if count - moved <= 0 then
            return moved
        end
    end
    return moved
end

return InvManager
