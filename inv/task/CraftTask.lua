local Task = require 'inv.task.Task'
local WaitTask = require 'inv.task.WaitTask'
local Item = require 'inv.Item'

-- Represents a crafting operation in progress.
local CraftTask = Task:subclass()

-- dest and destSlot are optional.
function CraftTask:init(server, parent, recipe, dest, destSlot)
    CraftTask.superClass.init(self, server, parent)
    self.machine = nil
    self.recipe = recipe
    self.dest = dest
    self.destSlot = destSlot
end

function CraftTask:run()
    if not self.machine then
        -- Check if any required input items are missing.
        local rem = self.server.invManager:tryMatchAll(self.recipe.input)
        if #rem > 0 then
            -- Queue tasks to obtain any missing input items.
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
            return false
        end
        print("crafting")
        self.machine:craft(self.recipe, self.dest, self.destSlot)
    end
    print("pulling output")
    self.machine:pullOutput()
    if not self.machine:busy() then
        return true
    end
    return false
end

return CraftTask
