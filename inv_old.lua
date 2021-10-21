local p = peripheral.getNames()

InvServer = {}

local function itemCreate(name,stacks)
    return {
        ["name"]=name,
        ["stacks"]=stacks
    }
end

local function itemStackCreate(name,count,slot,container)
    return {
        ["name"]=name,
        ["count"]=count,
        ["slot"]=slot,
        ["container"]=container,
    }
end

local function detailsCreate(details)
    return {
        ["displayName"]=details.displayName,
        ["maxCount"]=details.maxCount,
        [tags]=details.tags
    }
end

function InvServer:scanInventory(invName)
    local inv = peripheral.wrap(invName)
    if inv.list then
        local inv_items = inv.list()
        for slot,item in pairs(inv_items) do
            if not self.items[item.name] then
                self.items[item.name] = itemCreate(item.name,{})
            end
            table.insert(self.items[item.name].stacks, itemStackCreate(item.name, item.count, slot, invName))
            if not self.itemDB[item.name] then
                local details = inv.getItemDetail(slot)
                self.itemDB[item.name] = detailsCreate(details)
            end
        end
        self.inventories[invName] = {
            ["name"]=invName,
            ["size"]=inv.size(),
            ["items"]=inv_items,
            ["type"]=peripheral.getType(invName)
        }
    end
end

-- Ideally, we will call this function as little as possible?
function InvServer:scanItems()
    local items = {}
    local inventories = {}
    for i,inventory in pairs(peripheral.getNames()) do
        self:scanInventory(inventory)
    end
    return items
end

function InvServer:pullItemsExt(name,count,dest,destSlot)
    local moved = 0
    if self.items[name] then
        for i=#self.items[name].stacks,1,-1 do
            local stack = self.items[name].stacks[i]
            local inv = peripheral.wrap(stack.container)
            local details = inv.getItemDetail(stack.slot)
            if details.name == name then
                local toMove = math.min(details.count,count - moved)
                local n = inv.pushItems(dest, stack.slot, toMove, destSlot)
                moved = moved + n
                stack.count = details.count - n
            end
            if stack.count <= 0 then
                table.remove(self.items[name].stacks,i)
            end
            if count - moved <= 0 then
                return moved
            end
        end
    end
    return moved
end

function InvServer:pushItemsExt(count,src,srcSlot)
    local moved = 0
    local srcDetail = peripheral.wrap(src).getItemDetail(srcSlot)
    
    if self.items[name] then
        for i=#self.items[name].stacks,1,-1 do
            local stack = self.items[name].stacks[i]
            local inv = peripheral.wrap(stack.container)
            local details = inv.getItemDetail(stack.slot)
            if details.name == name then
                local toMove = math.min(details.count-self.itemDB[srcDetail.name].maxCount,count - moved)
                local n = inv.pullItems(src, srcSlot, toMove, stack.slot)
                moved = moved + n
                stack.count = details.count + n
            end
            if count - moved <= 0 then
                return moved
            end
        end
    end
    return moved
end