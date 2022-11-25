local Task = require 'inv.task.Task'
local WaitTask = require 'inv.task.WaitTask'

local CraftTask = Task:subclass()

function CraftTask:init(server, parent, recipe, dest)
    CraftTask.superClass.init(self, server, parent)
    self.machine = nil
    self.recipe = recipe
    self.dest = dest
end

function CraftTask:run()
    if not self.machine then
        local rem = self.server.invManager:tryMatchAll(self.recipe.input)
        if #rem > 0 then
            print("item dependencies required")
            for i, item in ipairs(rem) do
                local recipe = self.server.craftManager:findRecipe(item)
                if recipe then
                    self.server.taskManager:addTask(CraftTask(self.server, self, recipe))
                else
                    self.server.taskManager:addTask(WaitTask(self.server, self, item))
                end
            end
            return false
        end
        print(self.recipe.machine)
        self.machine = self.server.craftManager:findMachine(self.recipe.machine)
        if not self.machine then
            print("no machine")
            return false
        end
        print("crafting")
        self.machine:craft(self.recipe, self.dest)
    end
    self.machine:pullOutput()
    if not self.machine:busy() then
        return true
    end
    return false
end

return CraftTask
