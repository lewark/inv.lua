local Machine = require 'inv.device.Machine'
local Common = require 'inv.Common'

local Workbench = Machine:subclass()

function Workbench:init(server)
    Workbench.superClass.init(self, server, Common.getNameLocal(), "inv:workbench", {})
    self.slots = {
        [1]=1,  [2]=2,  [3]=3,
        [4]=5,  [5]=6,  [6]=7,
        [7]=9,  [8]=10, [9]=11,
        [10]=16
    }
end

function Workbench:craft(recipe)
    Workbench.superClass.craft(self, recipe)
    turtle.select(self:mapSlot(10))
    turtle.craft()
    self:pullOutput()
end

function Workbench:getItemDetail(slot)
    return turtle.getItemDetail(slot, true)
end

return Workbench
