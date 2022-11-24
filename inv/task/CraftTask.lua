local Task = require 'inv.task.Task'

local CraftTask = Task:subclass()

function CraftTask:init(server, parent, recipe)
    CraftTask.superClass.init(server, parent)
    self.machine = nil
    self.recipe = recipe
end

function CraftTask:run()
    if not self.machine then
        for slot, item in pairs(recipe.input) do

        end
        self.machine = server.craftManager.findMachine(recipe.machine)
        if not self.machine then
            return false
        end
        self.machine.craft(self.recipe)
    end
    self.machine:pullOutput()
    if not self.machine:busy() then
        return true
    end
    return false
end

return FetchTask
