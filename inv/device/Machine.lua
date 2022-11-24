local Device = require 'inv.device.Device'
local Common = require 'inv.Common'

local Machine = Device:subclass()

function Machine:init(server, name, deviceType, config)
    Machine.superClass.init(self, server, name, deviceType, config)
    self.recipe = {}
    self.slots = self.config.slots
    self.busy = false
    self.remainingOutput = {}
    table.insert(server.craftManager.machines, self)
end

function Machine:destroy()
    Common.removeItem(server.craftManager.machines, self)
end

function Machine:mapSlot(virtSlot)
    if self.slots then
        return self.slots[virtSlot]
    end
    return virtSlot
end

function Machine:craft(recipe)
    if self.busy() then error("Machine " .. self.name .. " busy") end
    self.recipe = recipe
    self.remainingOutput = Common.deepCopy(self.recipe.output)
    for virtSlot, item in pairs(self.recipe.input)
        self.server.invManager.pushItemsTo(item, self, self:mapSlot(virtSlot))
    end
end

function Machine:busy()
    for virtSlot, rem in pairs(self.remainingOutput) do
        if rem and rem.count > 0 then
            return true
        end
    end
    return false
end

function Machine:handleOutputSlot(item, virtSlot, realSlot)
    if item then
        local rem = self.remainingOutput[virtSlot]
        if rem and rem.name == item.name and rem.count >= item.count then
            n = self.server.invManager.pullItemsFrom(self, realSlot)
            rem.count = rem.count - n
            if rem.count == 0 then
                self.remainingOutput[virtSlot] = nil
            end
        else
            error("unexpected output " .. item.name .. " in " .. self.name)
        end
    end
end

function Machine:pullOutput()
    local items = interface.list()
    for virtSlot, rem in pairs(self.remainingOutput) do
        local realSlot = self:mapSlot(virtSlot)
        local item = items[realSlot]
        self:handleOutputSlot(item, virtSlot, realSlot)
    end
end

return Machine
