local Machine = require 'inv.device.Machine'
local Common = require 'inv.Common'

local Workbench = Machine:subclass()

function Workbench:init(system)
    Workbench.superClass.init(self, system, nil)
    self.name = Common.getNameLocal()
    self.type = "inv:workbench"
    self.inSlots = {
        [1]=1,  [2]=2,  [3]=3,
        [4]=5,  [5]=6,  [6]=7,
        [7]=9,  [8]=10, [9]=11
    }
    self.outSlots = {[1]=16}
end

function Workbench:craft()
    Workbench.superClass.craft(self, recipe)
    turtle.select(self.outSlots[1])
    turtle.craft()
    self:pullOutput()
end

function Workbench:busy()
    return false
end

function Workbench:pullOutput()
    local virtSlot = 1
    local realSlot = self.outSlots[virtSlot]
    local item = turtle.getItemDetail(realSlot)
    self:handleOutputSlot(item, virtSlot, realSlot)

    -- clear out any extra
    for virtSlot, realSlot in pairs(self.inSlots) do
        if turtle.getItemCount(realSlot) > 0 then
            self.invManager.pullItemsFrom(self, realSlot)
        end
    end
end


return Workbench
