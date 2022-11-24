local Device = require 'inv.device.Device'
local Common = require 'inv.Common'

local Machine = Device:subclass()

function Machine:init(system, name, deviceType)
    Machine.superClass.init(self, system, name, deviceType)
    self.recipe = {}
    self.inSlots = self.config.inSlots
    self.outSlots = self.config.outSlots
    self.busy = false
    self.remainingOutput = {}
    table.insert(system.craftManager.machines, self)
end

function Machine:destroy()
    Common.removeItem(system.craftManager.machines, self)
end

function Machine:craft(recipe)
    if self.busy() then error("Machine " .. self.name .. " busy") end
    self.recipe = recipe
    self.remainingOutput = Common.deepCopy(self.recipe.output)
    for virtSlot, item in pairs(self.recipe.input)
        self.system.invManager.pushItemsTo(item, self, self.inSlots[virtSlot])
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
            n = self.system.invManager.pullItemsFrom(self, realSlot)
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
    for virtSlot, realSlot in pairs(self.outSlots) do
        local item = items[realSlot]
        self:handleOutputSlot(item, virtSlot, realSlot)
    end
end

return Machine
