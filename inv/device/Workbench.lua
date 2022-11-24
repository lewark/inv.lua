local Machine = require 'inv.device.Machine'
local Common = require 'inv.Common'

local Workbench = Machine:subclass()

function Workbench:init(system)
    Workbench.superClass.init(self, system, nil)
    self.name = Common.getNameLocal()
    self.type = "inv:workbench"
    self.slots = {
        [1]=1,  [2]=2,  [3]=3,
        [4]=5,  [5]=6,  [6]=7,
        [7]=9,  [8]=10, [9]=11,
        [10]=16
    }
end

function Workbench:craft()
    Workbench.superClass.craft(self, recipe)
    turtle.select(self:mapSlot(10))
    turtle.craft()
    self:pullOutput()
end

function Workbench:pullOutput()
    for virtSlot, rem in pairs(self.remainingOutput) do
        local realSlot = self:mapSlot(virtSlot)
        local item = turtle.getItemDetail(realSlot)
        self:handleOutputSlot(item, virtSlot, realSlot)
    end
end

return Workbench
