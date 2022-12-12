local Device = require 'inv.device.Device'
local Common = require 'inv.Common'

-- Represents a crafting machine.
local Machine = Device:subclass()

function Machine:init(server, name, deviceType, config)
    Machine.superClass.init(self, server, name, deviceType, config)
    -- Recipe: The recipe currently being crafted by this Machine.
    self.recipe = nil
    -- table<int, int>: Optional mapping between virtual slots used in recipes
    -- and real slots in the Machine's inventory.
    self.slots = nil
    -- Device: Where crafted items should be sent. Optional.
    self.dest = nil
    -- int: Slot within self.dest where crafted items should be sent. Optional.
    self.destSlot = nil
    -- table<int, Item>: Remaining items that this Machine is currently crafting.
    self.remaining = {}
    
    if self.config.slots then
        self.slots = Common.integerKeys(self.config.slots)
    end

    self.server.craftManager:addMachine(self)
end

function Machine:destroy()
    self.server.craftManager:removeMachine(self)
end

-- Maps a virtual slot number from a Recipe
-- to an actual slot in this Machine's inventory.
function Machine:mapSlot(virtSlot)
    if self.slots then
        return self.slots[virtSlot]
    end
    return virtSlot
end

-- Starts a crafting operation.
-- dest and destSlot are optional.
function Machine:craft(recipe, dest, destSlot)
    if self:busy() then error("machine " .. self.name .. " busy") end
    self.recipe = recipe
    self.dest = dest
    self.destSlot = destSlot
    self.remaining = {}
    for slot, item in pairs(self.recipe.output) do
        self.remaining[slot] = item.count
    end
    for virtSlot, crit in pairs(self.recipe.input) do
        local n = self.server.invManager:pushItemsTo(crit, self, self:mapSlot(virtSlot))
        assert(n == crit.count)
    end
end

-- Returns true if this machine is currently crafting.
function Machine:busy()
    return self.recipe ~= nil
end

-- Empties an output slot of the machine and counts any crafted items.
function Machine:handleOutputSlot(item, virtSlot, realSlot)
    if item then
        n = self.server.invManager:pullItemsFrom(item, self, realSlot)
        if self.recipe.output[virtSlot]:matches(item) then
            self.remaining[virtSlot] = self.remaining[virtSlot] - n
            if self.dest then
                local outItem = self.recipe.output[virtSlot]:copy()
                outItem.count = n
                self.server.invManager:pushItemsTo(outItem, self.dest, self.destSlot)
            end
        else
            print("unexpected output " .. item.name .. " in " .. self.name)
        end
    end
end

-- Empties all output slots of this machine, counting the crafted items
-- and updating the machine state as necessary.
function Machine:pullOutput()
    for virtSlot, rem in pairs(self.remaining) do
        local realSlot = self:mapSlot(virtSlot)
        local item = self:getItemDetail(realSlot)
        self:handleOutputSlot(item, virtSlot, realSlot)
    end
    for virtSlot, rem in pairs(self.remaining) do
        if rem > 0 then
            return
        end
    end
    self.recipe = nil
end

return Machine
