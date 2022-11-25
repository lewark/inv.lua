local Task = require 'inv.task.Task'
local FetchTask = require 'inv.task.FetchItemTask'

local CraftTask = Task:subclass()

function CraftTask:init(server, parent, recipe)
    CraftTask.superClass.init(self, server, parent)
    self.machine = nil
    self.recipe = recipe
end

function CraftTask:run()
    if not self.machine then
        local rem = self.server.invManager:tryMatchAll(self.recipe.input)
        if #rem > 0 then
            for i, item in ipairs(rem) do
                local recipe = self.server.craftManager:findRecipe(item)
                if recipe then
                    self.server.taskManager:addTask(CraftTask(self.server, self, recipe))
                else
                    self.server.taskManager:addTask(FetchTask(self.server, self, item))
                end
            end
            return false
        end

        self.machine = server.craftManager:findMachine(recipe.machine)
        if not self.machine then
            return false
        end
        self.machine:craft(self.recipe)
    end
    self.machine:pullOutput()
    if not self.machine:busy() then
        return true
    end
    return false
end

return CraftTask
