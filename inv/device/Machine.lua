local Device = require 'inv.device.Device'
local Common = require 'inv.Common'

local Machine = Device:subclass()

function Machine:init(server, name, deviceType, config)
    Machine.superClass.init(self, server, name, deviceType, config)
    self.recipe = {}
    self.slots = self.config.slots
    self.remaining = {}

    self.server.craftManager:addMachine(self)
end

function Machine:destroy()
    self.server.craftManager:removeMachine(self)
end

function Machine:mapSlot(virtSlot)
    if self.slots then
        return self.slots[virtSlot]
    end
    return virtSlot
end

function Machine:craft(recipe)
    if self:busy() then error("Machine " .. self.name .. " busy") end
    self.recipe = recipe
    self.remaining = {}
    for slot, item in pairs(self.recipe.output) do
        self.remaining[slot] = item.count
    end
    for virtSlot, crit in pairs(self.recipe.input)
        self.server.invManager.pushItemsTo(crit, self, self:mapSlot(virtSlot))
    end
end

function Machine:busy()
    return self.recipe ~= nil
end

function Machine:handleOutputSlot(item, virtSlot, realSlot)
    if item then
        n = self.server.invManager.pullItemsFrom(self, realSlot)
        if self.recipe.output[virtSlot]:matches(item) then
            self.remaining[virtSlot] = self.remaining[virtSlot] - n
        else
            print("unexpected output " .. item.name .. " in " .. self.name)
        end
    end
end

function Machine:pullOutput()
    for virtSlot, rem in pairs(self.remainingOutput) do
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
