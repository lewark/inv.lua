local Machine = require 'inv.device.Machine'
local Common = require 'inv.Common'

-- Represents a crafting table peripheral.
-- Must be connected directly to the server turtle.
local Workbench = Machine:subclass()

function Workbench:init(server, name, deviceType)
    Workbench.superClass.init(self, server, name, deviceType, {})
    self.slots = {
        [1]=1,  [2]=2,  [3]=3,
        [4]=5,  [5]=6,  [6]=7,
        [7]=9,  [8]=10, [9]=11,
        [10]=16
    }
    self.location = Common.getNameLocal()
end

function Workbench:craft(recipe, dest, destSlot)
    Workbench.superClass.craft(self, recipe, dest, destSlot)
    turtle.select(self:mapSlot(10))
    turtle.craft()
    self:pullOutput()
end

function Workbench:getItemDetail(slot)
    return turtle.getItemDetail(slot, true)
end

return Workbench
