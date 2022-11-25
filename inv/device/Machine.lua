local Device = require 'inv.device.Device'
local Common = require 'inv.Common'
local ItemCriteria = require 'inv.ItemCriteria'

local Machine = Device:subclass()

function Machine:init(server, name, deviceType, config)
    Machine.superClass.init(self, server, name, deviceType, config)
    self.recipe = nil
    self.slots = nil
    self.dest = nil
    self.destSlot = nil
    if self.config.slots then
        self.slots = Common.integerKeys(self.config.slots)
    end
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

function Machine:craft(recipe, dest, destSlot)
    if self:busy() then error("Machine " .. self.name .. " busy") end
    self.recipe = recipe
    self.dest = dest
    self.destSlot = destSlot
    self.remaining = {}
    for slot, item in pairs(self.recipe.output) do
        self.remaining[slot] = item.count
    end
    for virtSlot, crit in pairs(self.recipe.input) do
        --print("push start")
        self.server.invManager:pushItemsTo(crit, self, self:mapSlot(virtSlot))
        --print("push end")
    end
end

function Machine:busy()
    return self.recipe ~= nil
end

function Machine:handleOutputSlot(item, virtSlot, realSlot)
    if item then
        n = self.server.invManager:pullItemsFrom(item, self, realSlot)
        if self.recipe.output[virtSlot]:matches(item) then
            self.remaining[virtSlot] = self.remaining[virtSlot] - n
            if self.dest then
                local outItem = self.recipe.output[virtSlot]
                self.server.invManager:pushItemsTo(
                    ItemCriteria({name=outItem.name,tags=outItem.tags,count=n}),
                    self.dest, self.destSlot
                )
            end
        else
            print("unexpected output " .. item.name .. " in " .. self.name)
        end
    end
end

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
