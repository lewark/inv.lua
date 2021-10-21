local p = peripheral.getNames()

InvServer = {}

local function itemCreate(name,count)
    return {
        ["name"]=name,
        ["count"]=count
    }
end

local function detailsCreate(details)
    return {
        ["displayName"]=details.displayName,
        ["maxCount"]=details.maxCount,
        [tags]=details.tags
    }
end

function InvServer:new()    
    return setmetatable({itemDB={}},{__index=InvServer})
end

function InvServer:scanInventory(invName, inv, items)    
    local inv_items = inv.list()
    for slot,item in pairs(inv_items) do
        if not items[item.name] then
            items[item.name] = itemCreate(item.name,0)
        end
        items[item.name].count = items[item.name].count + item.count
        if not self.itemDB[item.name] then
            local details = inv.getItemDetail(slot)
            self.itemDB[item.name] = detailsCreate(details)
        end
    end
end

function InvServer:getInventories()
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
function InvServer:scanItems()
    items = {}
    for name,inventory in pairs(self:getInventories()) do
        self:scanInventory(name,inventory,items)
    end
end

-- Attempts to pull a given amount of items from the system
-- destSlot is optional
function InvServer:pullItemsExt(name,count,dest,destSlot)
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

-- Attempts to push a given amount of items into the system
function InvServer:pushItemsExt(count,src,srcSlot)
    local moved = 0
    local srcDetail = peripheral.wrap(src).getItemDetail(srcSlot)
    
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

