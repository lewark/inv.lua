local Machine = require 'inv.Machine'

local Workbench = Machine:subclass()

function Workbench:init(system)
    Workbench.superClass.init(self, system, nil)
    self.name = "workbench"
    self.type = "inv:workbench"
    self.inSlots = {
        [1]=1,  [2]=2,  [3]=3,
        [4]=5,  [5]=6,  [6]=7,
        [7]=9,  [8]=10, [9]=11
    }
    self.outSlots = {[1]=16}
end

function Workbench:craft()
    turtle.craft()
end

return Workbench
