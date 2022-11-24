local Device = require 'Device'

local Machine = Device:subclass()

function Machine:init(system, name)
    Machine.superClass.init(self, system, name)
    self.recipes = {}
    self.inSlots = self.config.inSlots
    self.outSlots = self.config.outSlots
    self.busy = false
end

function Machine:craft(recipe)
end

return Machine